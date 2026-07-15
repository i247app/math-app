import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/classroom/application/classroom_cubit.dart';
import 'package:numi/features/classroom/presentation/screens/teacher_class_detail_screen.dart';
import 'package:numi/features/classroom/presentation/screens/teacher_create_class_screen.dart';
import 'package:numi/features/classroom/widgets/teacher_create/teacher_create_class_result.dart';
import 'package:numi/features/home/data/cache/home_profile_cache.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/home/teacher/data/cache/teacher_home_snapshot.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/homework/presentation/screens/teacher_homework_detail_screen.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_empty_assignments_panel.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_helpers.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';

import 'package:numi/features/home/teacher/home/helpers/teacher_home_helpers.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_assignments_loading_panel.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_class_carousel.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_class_section_header.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_hero_card.dart';
import 'package:numi/shared/widgets/app_staggered_entrance.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_home_hero_skeleton.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_home_section_header_skeleton.dart';
import 'package:numi/shared/widgets/app_section_header.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_loading_panel.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_no_class_panel.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_recent_assignment_carousel.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_top_bar.dart';

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
  State<TeacherHomeTab> createState() => _TeacherRoleTabState();
}

class _TeacherRoleTabState extends State<TeacherHomeTab> {
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
      _loadClassrooms();
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
      final layout = await cache.loadLayout(
        profileId: profileId,
        loader: () => _homeLayoutService.getLayout(profileId: profileId),
      );
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
      ]..sort(compareRecentAssignments);

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

    return AppStaggeredEntrance(
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
      _showError(context.readText(AppKeys.teacherClassOpenFailed));
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

  void _showError(String message) {
    context.showErrorDialog(message);
  }

  Widget _buildClassroomSection({
    required double scale,
    required bool isProfileComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isInitialHomeLoading)
          TeacherAppSectionHeaderSkeleton(scale: scale)
        else
          TeacherClassSectionHeader(
            scale: scale,
            hasClasses: _classrooms.isNotEmpty,
            onAdd: _handleClassCreateAction,
            onViewAll: widget.onOpenClassroomTab,
          ),
        SizedBox(height: 12 * scale),
        if (_isInitialHomeLoading)
          TeacherLoadingPanel(scale: scale)
        else if (_error != null && _classrooms.isEmpty)
          AppRetryPanel(
            scale: scale,
            message: _error!,
            onRetry: _refreshClassrooms,
          )
        else if (_classrooms.isEmpty)
          Column(
            children: [
              TeacherNoClassPanel(
                scale: scale,
                isProfileComplete: isProfileComplete,
                onCreate: _handleClassCreateAction,
              ),
            ],
          )
        else
          Column(
            children: [
              TeacherClassCarousel(
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
          TeacherAppSectionHeaderSkeleton(scale: scale)
        else
          AppSectionHeader(
            scale: scale,
            title: context.getText(AppKeys.teacherRecentlyAssigned),
            actionLabel: context.getText(AppKeys.viewAllUpper),
            onAction: widget.onOpenStudyTab,
          ),
        SizedBox(height: 12 * scale),
        if (_isInitialAssignmentsLoading)
          TeacherAssignmentsLoadingPanel(scale: scale)
        else if (_recentAssignments.isEmpty)
          Column(
            children: [
              TeacherEmptyAssignmentsPanel(
                message: context.getText(AppKeys.teacherNoAssignments),
              ),
            ],
          )
        else ...[
          TeacherRecentAssignmentCarousel(
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
              child: TeacherTopBar(
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
                        ? TeacherHomeHeroSkeleton(scale: scale)
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
