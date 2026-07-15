import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/classroom/application/classroom_cubit.dart';
import 'package:numi/features/classroom/application/classroom_state.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/classroom/presentation/screens/student_class_detail_screen.dart';
import 'package:numi/features/home/widgets/shell/home_tab_header.dart';
import 'package:numi/features/home/constants/home_visual_constants.dart';
import 'package:numi/features/classroom/widgets/student_class_search_content.dart';
import 'package:numi/features/home/student/shared/widgets/student_inline_error_panel.dart';
import 'package:numi/features/home/student/shared/widgets/student_state_card.dart';
import 'package:numi/features/home/student/classroom/widgets/student_classroom_tab_card.dart';
import 'package:numi/features/home/student/classroom/widgets/student_join_another_classroom_title.dart';
import 'package:numi/features/home/student/classroom/widgets/student_classroom_loading_region.dart';

class StudentClassroomTab extends StatefulWidget {
  const StudentClassroomTab({
    super.key,
    required this.bottomPadding,
    required this.scale,
    required this.user,
    required this.activeProfile,
    required this.classroomService,
    required this.isActive,
    this.activeRefreshTick = 0,
  });

  final double bottomPadding;
  final double scale;
  final LoginUser? user;
  final StudentProfile? activeProfile;
  final ClassroomService classroomService;
  final bool isActive;
  final int activeRefreshTick;

  @override
  State<StudentClassroomTab> createState() => _StudentClassroomTabState();
}

class _StudentClassroomTabState extends State<StudentClassroomTab> {
  late final ClassroomService _classroomService = widget.classroomService;

  int? get _profileId =>
      ActiveProfileSession.profileStableId(widget.activeProfile);

  ClassroomCollectionState get _classroomCollection {
    final profileId = _profileId;
    if (profileId == null || profileId <= 0) {
      return const ClassroomCollectionState(profileId: 0);
    }
    return context.read<ClassroomCubit>().joined(profileId);
  }

  List<ClassroomModel> get _classrooms => _classroomCollection.classrooms;

  bool get _isLoading => _classroomCollection.isLoading;

  bool get _hasLoadedClassrooms => _classroomCollection.hasLoaded;

  String? get _error {
    final profileId = _profileId;
    if (profileId == null || profileId <= 0) {
      return context.readText(AppKeys.studentMissingProfileId);
    }
    return _classroomCollection.errorMessage == null
        ? null
        : context.readText(AppKeys.studentClassroomLoadFailed);
  }

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadClassrooms();
    }
  }

  @override
  void didUpdateWidget(covariant StudentClassroomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadClassrooms();
      return;
    }
    if (!widget.isActive) {
      return;
    }
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (oldProfileId != profileId) {
      _loadClassrooms();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadClassrooms(forceRefresh: true);
    }
  }

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId = _profileId;
    if (profileId == null || profileId <= 0) {
      return;
    }
    await context.read<ClassroomCubit>().loadJoined(
      profileId,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _refreshClassrooms() {
    return _loadClassrooms(forceRefresh: true);
  }

  Future<void> _openClassDetail(ClassroomModel classroom) async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final classroomId = classroom.stableId;
    if (profileId == null || profileId <= 0 || classroomId == null) {
      context.showErrorDialog(context.readText(AppKeys.teacherClassOpenFailed));
      return;
    }

    HapticFeedback.selectionClick();
    final classroomCubit = context.read<ClassroomCubit>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: classroomCubit,
          child: StudentClassDetailScreen(
            classroomId: classroomId,
            profileId: profileId,
            initialClassroom: classroom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = _profileId;
    if (profileId != null && profileId > 0) {
      context.select<ClassroomCubit, ClassroomCollectionState>(
        (cubit) => cubit.joined(profileId),
      );
    }
    final canLoadContent = profileId != null && profileId > 0;
    final isInitialLoading =
        canLoadContent &&
        _isLoading &&
        _classrooms.isEmpty &&
        !_hasLoadedClassrooms;
    final scale = widget.scale;
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: context.themeColors.pageBackground,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Visibility(
                    visible: !isInitialLoading,
                    maintainState: true,
                    child: RefreshIndicator(
                      onRefresh: _refreshClassrooms,
                      color: homeTeal,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.zero,
                        children: [
                          HomeTabHeader(
                            title: context.getText(AppKeys.studentClassroom),
                            scale: scale,
                            topInset: topInset,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              20 * scale,
                              20 * scale,
                              20 * scale,
                              widget.bottomPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_error != null && _classrooms.isEmpty)
                                  StudentInlineErrorPanel(
                                    message: _error!,
                                    onRetry: _refreshClassrooms,
                                  )
                                else if (_classrooms.isEmpty)
                                  const StudentStateCard(
                                    titleKey: AppKeys.studentNoClassroomsTitle,
                                    messageKey:
                                        AppKeys.studentNoClassroomsMessage,
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final cardWidth =
                                          (constraints.maxWidth - 10 * scale) /
                                          2;
                                      return Wrap(
                                        spacing: 10 * scale,
                                        runSpacing: 12 * scale,
                                        children: [
                                          for (final classroom in _classrooms)
                                            SizedBox(
                                              width: cardWidth,
                                              child: StudentClassroomTabCard(
                                                classroom: classroom,
                                                onTap: () =>
                                                    _openClassDetail(classroom),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                SizedBox(height: 30 * scale),
                                const StudentJoinAnotherClassroomTitle(),
                                SizedBox(height: 14 * scale),
                                if (canLoadContent)
                                  StudentClassSearchContent(
                                    profileId: profileId,
                                    userId: widget.user?.id,
                                    activeRefreshTick: widget.activeRefreshTick,
                                    classroomService: _classroomService,
                                    onJoinRequested: _refreshClassrooms,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isInitialLoading)
                  const Positioned.fill(child: StudentClassroomLoadingRegion()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
