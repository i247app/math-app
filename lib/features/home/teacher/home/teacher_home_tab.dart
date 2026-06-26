part of '../../../classroom/presentation/teacher_classroom_screens.dart';

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
  })  : _exerciseService = exerciseService,
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

  List<ClassroomModel> get _classrooms => _layoutClassrooms;

  bool get _isLoading => _isLoadingHomeLayout;

  bool get _hasLoadedClassrooms => _hasLoadedHomeLayout;

  String? get _error {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId == null || profileId <= 0) {
      return context.readText(AppKeys.teacherMissingProfileId);
    }
    return _homeLayoutError;
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
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId != _loadedProfileId) {
      _loadClassrooms();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadClassrooms(forceRefresh: true);
    }
  }

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
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

    setState(() {
      _isLoadingHomeLayout = true;
      _isLoadingAssignments = true;
      if (_loadedProfileId != profileId) {
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
    } catch (error) {
      if (!mounted ||
          _loadedProfileId != profileId ||
          _homeLayoutRequestId != requestId) {
        return;
      }
      final message = error is HomeLayoutException
          ? error.message
          : context.readText(AppKeys.teacherStudyLoadFailed);
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

  Future<void> _refreshClassrooms() {
    return _loadClassrooms(forceRefresh: true);
  }

  Future<void> _openCreateClass() async {
    HapticFeedback.lightImpact();
    final previousClassroomIds = _classrooms
        .map((classroom) => classroom.stableId)
        .whereType<int>()
        .toSet();
    final result = await Navigator.of(context).push<_CreateClassResult>(
      MaterialPageRoute(
        builder: (_) => TeacherCreateClassScreen(
          user: widget.user,
          activeProfile: widget.activeProfile,
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
    if (!_isTeacherProfileComplete(widget.activeProfile)) {
      HapticFeedback.selectionClick();
      await widget.onCompleteProfile();
      return;
    }

    await _openCreateClass();
  }

  ClassroomModel? _findCreatedClassroom(
    _CreateClassResult result,
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
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (classroomId == null || profileId == null) {
      _showSnack(context.readText(AppKeys.teacherClassOpenFailed));
      return;
    }

    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TeacherClassDetailScreen(
          classroomId: classroomId,
          profileId: profileId,
          userId: widget.user?.id,
          initialClassroom: classroom,
          initiallyExpanded: initiallyExpanded,
        ),
      ),
    );
  }

  void _openAssignmentDetail(ClassroomExercise exercise) {
    final exerciseId = exercise.stableId;
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (exerciseId == null || profileId == null) {
      _showTeacherHomeworkSoon(context);
      return;
    }

    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherHomeworkDetailScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
          purpose: _teacherExercisePurpose(exercise),
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

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final isProfileComplete = _isTeacherProfileComplete(widget.activeProfile);

    return RefreshIndicator(
      color: _teacherTeal,
      onRefresh: _refreshClassrooms,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TeacherTopBar(
              profile: widget.activeProfile,
              topPadding: MediaQuery.paddingOf(context).top,
              scale: scale,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 22 * scale),
                  _TeacherHeroCard(scale: scale),
                  SizedBox(height: 28 * scale),
                  _TeacherClassSectionHeader(
                    scale: scale,
                    hasClasses: _classrooms.isNotEmpty,
                    onAdd: _handleClassCreateAction,
                    onViewAll: widget.onOpenClassroomTab,
                  ),
                  SizedBox(height: 12 * scale),
                  if (_isLoading &&
                      _classrooms.isEmpty &&
                      !_hasLoadedClassrooms)
                    _TeacherLoadingPanel(scale: scale)
                  else if (_error != null && _classrooms.isEmpty)
                    _TeacherErrorPanel(
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
                  SizedBox(height: 30 * scale),
                  _TeacherHomeSectionHeader(
                    scale: scale,
                    title: context.getText(AppKeys.teacherRecentlyAssigned),
                    onViewAll: widget.onOpenStudyTab,
                  ),
                  SizedBox(height: 12 * scale),
                  if (_isLoadingAssignments &&
                      _recentAssignments.isEmpty &&
                      !_hasLoadedAssignments)
                    _TeacherAssignmentsLoadingPanel(scale: scale)
                  else if (_recentAssignments.isEmpty)
                    Column(
                      children: [
                        _TeacherEmptyAssignmentsPanel(
                          message: context.getText(
                            AppKeys.teacherNoAssignments,
                          ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
