import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/data/home_layout_exception.dart';
import 'package:numi/features/home/data/teacher_home_snapshot.dart';
import 'package:numi/shared/widgets/teacher_empty_assignments_panel.dart';
import 'package:numi/features/classroom_exercise/helpers/teacher_exercise_helpers.dart';
import 'package:numi/shared/widgets/settings_action_card.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';

import 'package:numi/features/home/helpers/teacher/teacher_home_helpers.dart';
import 'package:numi/features/home/widgets/teacher/teacher_assignments_loading_panel.dart';
import 'package:numi/features/home/widgets/teacher/teacher_class_carousel.dart';
import 'package:numi/features/home/widgets/teacher/teacher_class_section_header.dart';
import 'package:numi/features/home/widgets/teacher/teacher_hero_card.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';
import 'package:numi/features/home/widgets/teacher/teacher_home_hero_skeleton.dart';
import 'package:numi/features/home/widgets/teacher/teacher_home_section_header_skeleton.dart';
import 'package:numi/shared/widgets/app_section_header.dart';
import 'package:numi/features/home/widgets/teacher/teacher_loading_panel.dart';
import 'package:numi/features/home/widgets/teacher/teacher_recent_assignment_carousel.dart';
import 'package:numi/features/home/widgets/teacher/teacher_top_bar.dart';

part 'teacher_home/data_actions.dart';
part 'teacher_home/navigation_actions.dart';
part 'teacher_home/sections.dart';

class TeacherHomeTab extends StatefulWidget {
  const TeacherHomeTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.onCompleteProfile,
    this.onOpenClassroomTab,
    this.onOpenStudyTab,
    HomeLayoutService? homeLayoutService,
    this.activeRefreshTick = 0,
    this.isActive = true,
    this.hasUnreadNotifications = false,
    this.onNotificationTap,
    this.onCreateClass,
    this.onOpenClassDetail,
    this.onOpenAssignmentDetail,
  }) : _homeLayoutService = homeLayoutService;

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final Future<void> Function() onCompleteProfile;
  final VoidCallback? onOpenClassroomTab;
  final VoidCallback? onOpenStudyTab;
  final int activeRefreshTick;
  final bool isActive;
  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationTap;
  final Future<ClassroomModel?> Function(BuildContext context)? onCreateClass;
  final Future<void> Function(
    BuildContext context,
    ClassroomModel classroom,
    bool initiallyExpanded,
  )?
  onOpenClassDetail;
  final void Function(BuildContext context, ClassroomExercise exercise)?
  onOpenAssignmentDetail;
  final HomeLayoutService? _homeLayoutService;

  @override
  State<TeacherHomeTab> createState() => _TeacherRoleTabState();
}

class _TeacherRoleTabState extends State<TeacherHomeTab> {
  late final HomeLayoutService _homeLayoutService =
      widget._homeLayoutService ?? context.read<HomeLayoutService>();

  bool _isLoadingHomeLayout = false;
  bool _hasLoadedHomeLayout = false;
  bool _isLoadingAssignments = false;
  bool _hasLoadedAssignments = false;
  int? _loadedProfileId;
  int _homeLayoutRequestId = 0;
  String? _homeLayoutError;
  List<ClassroomModel> _layoutClassrooms = const <ClassroomModel>[];
  List<ClassroomExercise> _recentAssignments = const <ClassroomExercise>[];
  final Set<String> _playedHomeEntrances = <String>{};

  List<ClassroomModel> get _classrooms => _layoutClassrooms;

  bool get _isInitialHomeLoading =>
      _isLoadingHomeLayout && !_hasLoadedHomeLayout && _classrooms.isEmpty;

  bool get _isInitialAssignmentsLoading =>
      _isLoadingAssignments &&
      !_hasLoadedAssignments &&
      _recentAssignments.isEmpty;

  String? get _error {
    final profileId = profileStableId(widget.activeProfile);
    if (profileId == null || profileId <= 0) {
      return context.readText(AppKeys.teacherMissingProfileId);
    }
    return _homeLayoutError;
  }

  String get _teacherHomeProfileKey {
    final profileId = profileStableId(widget.activeProfile);
    return 'profile-${profileId ?? 'none'}';
  }

  String get _classroomEntranceId {
    return '$_teacherHomeProfileKey-classrooms';
  }

  String get _heroEntranceId {
    return '$_teacherHomeProfileKey-hero';
  }

  String get _assignmentsEntranceId {
    return '$_teacherHomeProfileKey-assignments';
  }

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadClassrooms();
    }
  }

  @override
  void didUpdateWidget(covariant TeacherHomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadClassrooms();
      return;
    }
    if (!widget.isActive) {
      return;
    }
    final profileId = profileStableId(widget.activeProfile);
    if (profileId != _loadedProfileId) {
      _resetHomeEntrance();
      _loadClassrooms();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadClassrooms(forceRefresh: true);
    }
  }

  void _resetHomeEntrance() {
    _playedHomeEntrances.clear();
  }

  Widget _homeEntrance({
    required String id,
    required int order,
    required Widget child,
  }) {
    return AppStaggeredEntrance(
      key: ValueKey<String>('teacher-home-entrance-$id'),
      order: order,
      initiallyVisible: _playedHomeEntrances.contains(id),
      onFinished: () => _markHomeEntrancePlayed(id),
      child: child,
    );
  }

  void _markHomeEntrancePlayed(String id) {
    if (!mounted || _playedHomeEntrances.contains(id)) {
      return;
    }
    setState(() => _playedHomeEntrances.add(id));
  }

  @override
  Widget build(BuildContext context) {
    final isProfileComplete = isTeacherProfileComplete(widget.activeProfile);

    return RefreshIndicator(
      color: AppColors.teal520,
      onRefresh: _refreshClassrooms,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeacherTopBar(
              profile: widget.activeProfile,
              topPadding: MediaQuery.paddingOf(context).top,
              onNotificationTap: widget.onNotificationTap ?? () {},
              hasUnreadNotifications: widget.hasUnreadNotifications,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: teacherTabContentHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: _isInitialHomeLoading
                        ? const TeacherHomeHeroSkeleton()
                        : _homeEntrance(
                            id: _heroEntranceId,
                            order: 0,
                            child: const TeacherHeroCard(),
                          ),
                  ),
                  if (!isProfileComplete && !_isInitialHomeLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _homeEntrance(
                        id: '$_teacherHomeProfileKey-complete-profile',
                        order: 1,
                        child: SettingsActionCard(
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF008A52),
                          iconBackground: const Color(0xFFD6FFE3),
                          title: context.getText(
                            AppKeys.teacherCompleteProfile,
                          ),
                          subtitle: context.getText(
                            AppKeys.teacherCompleteProfileDescription,
                          ),
                          showLeadingIcon: false,
                          subtitleMaxLines: 2,
                          onTap: _openProfileCompletion,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: _isInitialHomeLoading
                        ? _buildClassroomSection(
                            isProfileComplete: isProfileComplete,
                          )
                        : _homeEntrance(
                            id: _classroomEntranceId,
                            order: isProfileComplete ? 1 : 2,
                            child: _buildClassroomSection(
                              isProfileComplete: isProfileComplete,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: _isInitialAssignmentsLoading
                        ? _buildRecentAssignmentsSection()
                        : _homeEntrance(
                            id: _assignmentsEntranceId,
                            order: isProfileComplete ? 2 : 3,
                            child: _buildRecentAssignmentsSection(),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateState(VoidCallback update) => setState(update);
}
