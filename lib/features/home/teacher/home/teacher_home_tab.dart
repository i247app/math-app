import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/classroom/presentation/bloc/classroom_cubit.dart';
import 'package:numi_flutter/features/classroom/presentation/teacher_classroom_screens.dart';
import 'package:numi_flutter/features/classroom/widgets/teacher_shared/teacher_member_summary_text.dart';
import 'package:numi_flutter/features/home/cache/home_profile_cache.dart';
import 'package:numi_flutter/features/home/home_api.dart';
import 'package:numi_flutter/features/home/teacher/cache/teacher_home_snapshot.dart';
import 'package:numi_flutter/features/home/teacher/shared/widgets/class_thumb.dart';
import 'package:numi_flutter/features/home/teacher/shared/widgets/teacher_skeleton_block.dart';
import 'package:numi_flutter/features/home/teacher/shared/widgets/teacher_skeleton_card.dart';
import 'package:numi_flutter/features/home/teacher/shared/widgets/teacher_skeleton_shimmer.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/homework/presentation/teacher_homework_screen.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';

part 'helpers/teacher_home_helpers.dart';
part 'widgets/teacher_assignment_skeleton_card.dart';
part 'widgets/teacher_assignments_loading_panel.dart';
part 'widgets/teacher_class_card.dart';
part 'widgets/teacher_class_carousel.dart';
part 'widgets/teacher_class_section_header.dart';
part 'widgets/teacher_class_skeleton_card.dart';
part 'widgets/teacher_hero_card.dart';
part 'widgets/teacher_home_entrance.dart';
part 'widgets/teacher_home_hero_skeleton.dart';
part 'widgets/teacher_home_section_header_skeleton.dart';
part 'widgets/teacher_home_section_header.dart';
part 'widgets/teacher_loading_panel.dart';
part 'widgets/teacher_no_class_panel.dart';
part 'widgets/teacher_recent_assignment_card.dart';
part 'widgets/teacher_recent_assignment_carousel.dart';
part 'widgets/teacher_skeleton_carousel.dart';
part 'widgets/teacher_top_bar.dart';

class TeacherHomeTab extends StatefulWidget {
  const TeacherHomeTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.scale,
    required this.onCompleteProfile,
    this.onOpenClassroomTab,
    this.onOpenStudyTab,
    ClassroomExerciseService? exerciseService,
    HomeLayoutService? homeLayoutService,
    this.activeRefreshTick = 0,
    this.isActive = true,
  }) : _exerciseService = exerciseService,
       _homeLayoutService = homeLayoutService;

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final double scale;
  final Future<void> Function() onCompleteProfile;
  final VoidCallback? onOpenClassroomTab;
  final VoidCallback? onOpenStudyTab;
  final int activeRefreshTick;
  final bool isActive;
  final ClassroomExerciseService? _exerciseService;
  final HomeLayoutService? _homeLayoutService;

  @override
  State<TeacherHomeTab> createState() => _TeacherHomeTabState();
}

class _TeacherHomeTabState extends State<TeacherHomeTab> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();
  late final HomeLayoutService _homeLayoutService =
      widget._homeLayoutService ?? HomeLayoutApi();

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

  bool get _isLoading => _isLoadingHomeLayout;

  bool get _hasLoadedClassrooms => _hasLoadedHomeLayout;

  bool get _isInitialHomeLoading =>
      _isLoadingHomeLayout && !_hasLoadedHomeLayout && _classrooms.isEmpty;

  bool get _isInitialAssignmentsLoading =>
      _isLoadingAssignments &&
      !_hasLoadedAssignments &&
      _recentAssignments.isEmpty;

  String? get _error {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      return context.readText(AppKeys.teacherMissingProfileId);
    }
    return _homeLayoutError;
  }

  String get _teacherHomeProfileKey {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    return 'profile-${profileId ?? 'none'}';
  }

  String get _classroomEntranceId {
    final phase = _teacherClassroomSectionPhase();
    return '$_teacherHomeProfileKey-classrooms-$phase';
  }

  String get _heroEntranceId {
    final phase = _isInitialHomeLoading ? 'loading' : 'ready';
    return '$_teacherHomeProfileKey-hero-$phase';
  }

  String get _assignmentsEntranceId {
    final phase = _teacherAssignmentsSectionPhase();
    return '$_teacherHomeProfileKey-assignments-$phase';
  }

  String _teacherClassroomSectionPhase() {
    if (_isLoading && _classrooms.isEmpty && !_hasLoadedClassrooms) {
      return 'loading';
    }
    if (_error != null && _classrooms.isEmpty) {
      return 'error';
    }
    if (_classrooms.isEmpty) {
      return 'empty';
    }
    return 'ready-${_classrooms.length}';
  }

  String _teacherAssignmentsSectionPhase() {
    if (_isLoadingAssignments &&
        _recentAssignments.isEmpty &&
        !_hasLoadedAssignments) {
      return 'loading';
    }
    if (_recentAssignments.isEmpty) {
      return 'empty';
    }
    return 'ready-${_recentAssignments.length}';
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
      _loadClassrooms(forceRefresh: true);
      return;
    }
    if (!widget.isActive) {
      return;
    }
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
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

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final requestId = ++_homeLayoutRequestId;
    if (profileId == null || profileId <= 0) {
      setState(() {
        _loadedProfileId = profileId;
        _layoutClassrooms = const <ClassroomModel>[];
        _recentAssignments = const <ClassroomExercise>[];
        _isLoadingHomeLayout = false;
        _hasLoadedHomeLayout = true;
        _isLoadingAssignments = false;
        _hasLoadedAssignments = true;
        _homeLayoutError = null;
      });
      return;
    }

    final cache = HomeProfileCache.instance;
    final cachedSnapshot = cache.getTeacher(profileId);
    if (!forceRefresh && cachedSnapshot != null) {
      setState(() => _applySnapshot(cachedSnapshot));
      if (!cachedSnapshot.isStale) {
        return;
      }
    }

    final hadRenderableContent =
        _hasLoadedHomeLayout && _loadedProfileId == profileId;
    setState(() {
      _isLoadingHomeLayout = true;
      _isLoadingAssignments = true;
      if (!hadRenderableContent) {
        _layoutClassrooms = const <ClassroomModel>[];
        _recentAssignments = const <ClassroomExercise>[];
        _hasLoadedHomeLayout = false;
        _hasLoadedAssignments = false;
      }
      _homeLayoutError = null;
      _loadedProfileId = profileId;
    });

    try {
      final layout = await _homeLayoutService.getLayout(profileId: profileId);
      if (!mounted ||
          _loadedProfileId != profileId ||
          _homeLayoutRequestId != requestId) {
        return;
      }
      final teacher = layout.teacher;
      final classrooms = layout.rooms.isNotEmpty
          ? layout.rooms
                .map((classroom) => classroom.classroom)
                .toList(growable: false)
          : teacher?.classrooms
                    .map((classroom) => classroom.classroom)
                    .toList(growable: false) ??
                const <ClassroomModel>[];
      final layoutAssignments = layout.tasks
          .where((task) => task.isAssigned)
          .map((task) => task.exercise)
          .whereType<ClassroomExercise>()
          .toList(growable: false);
      final assignments = <ClassroomExercise>[
        if (layout.tasks.isNotEmpty)
          ...layoutAssignments
        else
          ...?teacher?.assignedExercises,
      ]..sort(_compareRecentAssignments);

      setState(() {
        _layoutClassrooms = classrooms;
        _recentAssignments = assignments;
        _isLoadingHomeLayout = false;
        _hasLoadedHomeLayout = true;
        _isLoadingAssignments = false;
        _hasLoadedAssignments = true;
        _homeLayoutError = null;
      });
      cache.putTeacher(
        TeacherHomeSnapshot(
          profileId: profileId,
          layoutClassrooms: classrooms,
          recentAssignments: assignments,
          cachedAt: DateTime.now(),
        ),
      );
    } catch (error) {
      if (!mounted ||
          _loadedProfileId != profileId ||
          _homeLayoutRequestId != requestId) {
        return;
      }
      final message = error is HomeLayoutException
          ? error.message
          : context.readText(AppKeys.teacherStudyLoadFailed);
      if (hadRenderableContent) {
        setState(() {
          _isLoadingHomeLayout = false;
          _isLoadingAssignments = false;
          _homeLayoutError = message;
        });
        return;
      }
      setState(() {
        _layoutClassrooms = const <ClassroomModel>[];
        _recentAssignments = const <ClassroomExercise>[];
        _isLoadingHomeLayout = false;
        _hasLoadedHomeLayout = true;
        _isLoadingAssignments = false;
        _hasLoadedAssignments = true;
        _homeLayoutError = message;
      });
    }
  }

  void _applySnapshot(TeacherHomeSnapshot snapshot) {
    _loadedProfileId = snapshot.profileId;
    _layoutClassrooms = snapshot.layoutClassrooms;
    _recentAssignments = snapshot.recentAssignments;
    _isLoadingHomeLayout = false;
    _hasLoadedHomeLayout = true;
    _isLoadingAssignments = false;
    _hasLoadedAssignments = true;
    _homeLayoutError = null;
  }

  Future<void> _refreshClassrooms() {
    return _loadClassrooms(forceRefresh: true);
  }

  Widget _homeEntrance({
    required String id,
    required int order,
    required Widget child,
  }) {
    if (_playedHomeEntrances.contains(id)) {
      return child;
    }

    return _TeacherHomeEntrance(
      key: ValueKey<String>('teacher-home-entrance-$id'),
      order: order,
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

  Future<void> _openCreateClass() async {
    HapticFeedback.lightImpact();
    final previousClassroomIds = _classrooms
        .map((classroom) => classroom.stableId)
        .whereType<int>()
        .toSet();
    final classroomCubit = context.read<ClassroomCubit>();
    final result = await Navigator.of(context).push<TeacherCreateClassResult>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: classroomCubit,
          child: TeacherCreateClassScreen(
            user: widget.user,
            activeProfile: widget.activeProfile,
          ),
        ),
      ),
    );
    if (result != null) {
      await _refreshClassrooms();
      if (!mounted) {
        return;
      }
      final classroom = _findCreatedClassroom(result, previousClassroomIds);
      if (classroom != null) {
        await _openClassDetail(classroom, initiallyExpanded: true);
      }
    }
  }

  Future<void> _handleClassCreateAction() async {
    if (!isTeacherProfileComplete(widget.activeProfile)) {
      HapticFeedback.selectionClick();
      await widget.onCompleteProfile();
      return;
    }

    await _openCreateClass();
  }

  ClassroomModel? _findCreatedClassroom(
    TeacherCreateClassResult result,
    Set<int> previousClassroomIds,
  ) {
    final createdId = result.classroom?.stableId;
    if (createdId != null) {
      for (final classroom in _classrooms) {
        if (classroom.stableId == createdId) {
          return classroom;
        }
      }
      return result.classroom;
    }

    for (final classroom in _classrooms) {
      final id = classroom.stableId;
      if (id != null && !previousClassroomIds.contains(id)) {
        return classroom;
      }
    }
    return null;
  }

  Future<void> _openClassDetail(
    ClassroomModel classroom, {
    bool initiallyExpanded = false,
  }) async {
    final classroomId = classroom.stableId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (classroomId == null || profileId == null) {
      _showSnack(context.readText(AppKeys.teacherClassOpenFailed));
      return;
    }

    HapticFeedback.selectionClick();
    final classroomCubit = context.read<ClassroomCubit>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: classroomCubit,
          child: TeacherClassDetailScreen(
            classroomId: classroomId,
            profileId: profileId,
            userId: widget.user?.id,
            initialClassroom: classroom,
            initiallyExpanded: initiallyExpanded,
          ),
        ),
      ),
    );
  }

  void _openAssignmentDetail(ClassroomExercise exercise) {
    final exerciseId = exercise.stableId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (exerciseId == null || profileId == null) {
      showTeacherHomeworkSoon(context);
      return;
    }

    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherHomeworkDetailScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
          purpose: teacherExercisePurpose(exercise),
          exerciseService: _exerciseService,
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildClassroomSection({
    required double scale,
    required bool isProfileComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isInitialHomeLoading)
          _TeacherHomeSectionHeaderSkeleton(scale: scale)
        else
          _TeacherClassSectionHeader(
            scale: scale,
            hasClasses: _classrooms.isNotEmpty,
            onAdd: _handleClassCreateAction,
            onViewAll: widget.onOpenClassroomTab,
          ),
        SizedBox(height: 12 * scale),
        if (_isInitialHomeLoading)
          _TeacherLoadingPanel(scale: scale)
        else if (_error != null && _classrooms.isEmpty)
          TeacherErrorPanel(
            scale: scale,
            message: _error!,
            onRetry: _refreshClassrooms,
          )
        else if (_classrooms.isEmpty)
          Column(
            children: [
              _TeacherNoClassPanel(
                scale: scale,
                isProfileComplete: isProfileComplete,
                onCreate: _handleClassCreateAction,
              ),
            ],
          )
        else
          Column(
            children: [
              _TeacherClassCarousel(
                scale: scale,
                classrooms: _classrooms,
                onOpen: _openClassDetail,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRecentAssignmentsSection({required double scale}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isInitialAssignmentsLoading)
          _TeacherHomeSectionHeaderSkeleton(scale: scale)
        else
          _TeacherHomeSectionHeader(
            scale: scale,
            title: context.getText(AppKeys.teacherRecentlyAssigned),
            onViewAll: widget.onOpenStudyTab,
          ),
        SizedBox(height: 12 * scale),
        if (_isInitialAssignmentsLoading)
          _TeacherAssignmentsLoadingPanel(scale: scale)
        else if (_recentAssignments.isEmpty)
          Column(
            children: [
              TeacherEmptyAssignmentsPanel(
                message: context.getText(AppKeys.teacherNoAssignments),
              ),
            ],
          )
        else ...[
          _TeacherRecentAssignmentCarousel(
            scale: scale,
            assignments: _recentAssignments,
            onOpen: _openAssignmentDetail,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
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
            _homeEntrance(
              id: '$_teacherHomeProfileKey-top-bar',
              order: 0,
              child: _TeacherTopBar(
                profile: widget.activeProfile,
                topPadding: MediaQuery.paddingOf(context).top,
                scale: scale,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 22 * scale),
                  _homeEntrance(
                    id: _heroEntranceId,
                    order: 1,
                    child: _isInitialHomeLoading
                        ? _TeacherHomeHeroSkeleton(scale: scale)
                        : TeacherHeroCard(scale: scale),
                  ),
                  SizedBox(height: 28 * scale),
                  _homeEntrance(
                    id: _classroomEntranceId,
                    order: 2,
                    child: _buildClassroomSection(
                      scale: scale,
                      isProfileComplete: isProfileComplete,
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  _homeEntrance(
                    id: _assignmentsEntranceId,
                    order: 3,
                    child: _buildRecentAssignmentsSection(scale: scale),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
