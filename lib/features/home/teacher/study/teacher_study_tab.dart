part of '../../../classroom/presentation/teacher_classroom_screens.dart';

class TeacherStudyTab extends StatefulWidget {
  const TeacherStudyTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.scale,
    ClassroomService? classroomService,
    ClassroomExerciseService? exerciseService,
    this.activeRefreshTick = 0,
    this.isActive = true,
  })  : _classroomService = classroomService,
        _exerciseService = exerciseService;

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final double scale;
  final int activeRefreshTick;
  final bool isActive;
  final ClassroomService? _classroomService;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<TeacherStudyTab> createState() => _TeacherStudyTabState();
}

class _TeacherStudyTabState extends State<TeacherStudyTab> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  int _exerciseRequestId = 0;
  int? _loadedProfileId;
  int? _selectedClassroomId;
  String _selectedPurpose = classroomExercisePurposeHomework;
  bool _isLoadingExercises = false;
  bool _hasCompletedInitialLoad = false;
  String? _error;
  List<ClassroomExercise> _exercises = const <ClassroomExercise>[];

  ClassroomCollectionState get _classroomCollection {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId == null || profileId <= 0) {
      return const ClassroomCollectionState(profileId: 0);
    }
    return context.read<ClassroomCubit>().owned(profileId);
  }

  List<ClassroomModel> get _classrooms => _classroomCollection.classrooms;

  bool get _isLoadingClassrooms => _classroomCollection.isLoading;

  String? get _displayError => _classroomCollection.errorMessage ?? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadClassrooms();
    }
  }

  @override
  void didUpdateWidget(covariant TeacherStudyTab oldWidget) {
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
      _selectedClassroomId = null;
      _loadClassrooms();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadClassrooms(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    _exerciseRequestId++;
    final isInitialProfileLoad =
        !_hasCompletedInitialLoad || profileId != _loadedProfileId;
    if (profileId == null) {
      setState(() {
        _loadedProfileId = null;
        _exercises = const <ClassroomExercise>[];
        _error = context.readText(AppKeys.teacherMissingProfileId);
        _isLoadingExercises = false;
        _hasCompletedInitialLoad = true;
      });
      return;
    }

    setState(() {
      _loadedProfileId = profileId;
      _isLoadingExercises = true;
      if (isInitialProfileLoad) {
        _hasCompletedInitialLoad = false;
        _exercises = const <ClassroomExercise>[];
      }
      _error = null;
    });

    final collection = await context.read<ClassroomCubit>().loadOwned(
          profileId,
          forceRefresh: forceRefresh,
        );
    if (!mounted || profileId != _loadedProfileId) {
      return;
    }

    final selectedStillExists = _selectedClassroomId == null ||
        collection.classrooms.any(
          (classroom) => classroom.stableId == _selectedClassroomId,
        );
    if (!selectedStillExists) {
      _selectedClassroomId = null;
    }
    if (collection.errorMessage != null && collection.classrooms.isEmpty) {
      setState(() {
        _exercises = const <ClassroomExercise>[];
        _error = collection.errorMessage!.trim().isEmpty
            ? context.readText(AppKeys.teacherStudyLoadFailed)
            : collection.errorMessage;
        _isLoadingExercises = false;
        _hasCompletedInitialLoad = true;
      });
      return;
    }
    await _loadExercises();
  }

  Future<void> _refreshClassrooms() {
    return _loadClassrooms(forceRefresh: true);
  }

  Future<void> _loadExercises() async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId == null || _isLoadingClassrooms) {
      return;
    }

    final requestId = ++_exerciseRequestId;
    final classrooms = _selectedClassroomId == null
        ? _classrooms
        : _classrooms
            .where(
              (classroom) => classroom.stableId == _selectedClassroomId,
            )
            .toList(growable: false);
    final targets = classrooms
        .where((classroom) => classroom.stableId != null)
        .toList(growable: false);

    if (targets.isEmpty) {
      setState(() {
        _exercises = const <ClassroomExercise>[];
        _error = null;
        _isLoadingExercises = false;
        _hasCompletedInitialLoad = true;
      });
      return;
    }

    setState(() {
      _isLoadingExercises = true;
      _error = null;
    });

    final search = _searchController.text.trim();
    final batches = await Future.wait(
      targets.map(
        (classroom) => _loadExerciseBatch(
          classroomId: classroom.stableId!,
          profileId: profileId,
          search: search,
          purpose: _selectedPurpose,
        ),
      ),
    );
    if (!mounted ||
        requestId != _exerciseRequestId ||
        profileId != _loadedProfileId) {
      return;
    }

    final exercises = <ClassroomExercise>[];
    String? firstError;
    for (final batch in batches) {
      exercises.addAll(batch.exercises);
      firstError ??= batch.error;
    }
    exercises.sort(_compareTeacherStudyExercises);

    setState(() {
      _exercises = _deduplicateTeacherStudyExercises(exercises);
      _error = exercises.isEmpty ? firstError : null;
      _isLoadingExercises = false;
      _hasCompletedInitialLoad = true;
    });
  }

  Future<_TeacherStudyExerciseBatch> _loadExerciseBatch({
    required int classroomId,
    required int profileId,
    required String search,
    required String purpose,
  }) async {
    final fallbackError = context.readText(AppKeys.teacherStudyLoadFailed);
    try {
      final exercises = await _exerciseService.listExercises(
        classroomId: classroomId,
        profileId: profileId,
        search: search,
        purpose: purpose,
      );
      return _TeacherStudyExerciseBatch(exercises: exercises);
    } on ClassroomExerciseException catch (error) {
      return _TeacherStudyExerciseBatch(
        error: error.message.trim().isEmpty ? fallbackError : error.message,
      );
    } catch (_) {
      return _TeacherStudyExerciseBatch(error: fallbackError);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      _loadExercises,
    );
  }

  void _selectClassroom(int? classroomId) {
    if (_selectedClassroomId == classroomId) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedClassroomId = classroomId);
    _loadExercises();
  }

  void _selectPurpose(String purpose) {
    if (_selectedPurpose == purpose) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedPurpose = purpose);
    _loadExercises();
  }

  Future<void> _openCreateExercise() async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    final classroom = _createClassroomSelection;
    final classroomId = classroom?.stableId;
    if (profileId == null || classroom == null || classroomId == null) {
      _showSnack(context.readText(AppKeys.teacherNoOptions));
      return;
    }

    HapticFeedback.lightImpact();
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TeacherCreateHomeworkScreen(
          classroomId: classroomId,
          profileId: profileId,
          userId: widget.user?.id,
          initialClassroom: classroom,
          purpose: _selectedPurpose,
          exerciseService: _exerciseService,
          classroomService: _classroomService,
        ),
      ),
    );
    if (created == true) {
      await _loadExercises();
    }
  }

  ClassroomModel? get _createClassroomSelection {
    if (_selectedClassroomId != null) {
      for (final classroom in _classrooms) {
        if (classroom.stableId == _selectedClassroomId) {
          return classroom;
        }
      }
    }
    for (final classroom in _classrooms) {
      if (classroom.stableId != null) {
        return classroom;
      }
    }
    return null;
  }

  void _openExerciseDetail(ClassroomExercise exercise) {
    final exerciseId = exercise.stableId;
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (exerciseId == null || profileId == null) {
      _showTeacherHomeworkSoon(context);
      return;
    }

    final purpose = exercise.purpose?.trim().toUpperCase();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherHomeworkDetailScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
          purpose: purpose == classroomExercisePurposeExam
              ? classroomExercisePurposeExam
              : purpose == classroomExercisePurposeHomework
                  ? classroomExercisePurposeHomework
                  : _selectedPurpose,
          exerciseService: _exerciseService,
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId != null && profileId > 0) {
      context.select<ClassroomCubit, ClassroomCollectionState>(
        (cubit) => cubit.owned(profileId),
      );
    }
    final scale = widget.scale;
    final visibleExercises = _exercises.take(10).toList(growable: false);
    return ColoredBox(
      color: const Color(0xFFF9FFFF),
      child: Column(
        children: [
          HomeTabHeader(
            title: context.getText(AppKeys.teacherStudyTitle),
            scale: scale,
          ),
          Expanded(
            child: RefreshIndicator(
              color: _teacherTeal,
              onRefresh: _refreshClassrooms,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  19 * scale,
                  18 * scale,
                  19 * scale,
                  widget.bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _TeacherHomeworkAddButton(
                        onTap: _openCreateExercise,
                      ),
                    ),
                    SizedBox(height: 18 * scale),
                    _TeacherStudySearchField(
                      controller: _searchController,
                      scale: scale,
                      onChanged: _onSearchChanged,
                    ),
                    SizedBox(height: 14 * scale),
                    if (!_hasCompletedInitialLoad)
                      _TeacherStudyLoadingIndicator(scale: scale)
                    else ...[
                      _TeacherStudyClassFilters(
                        classrooms: _classrooms,
                        selectedClassroomId: _selectedClassroomId,
                        scale: scale,
                        onSelected: _selectClassroom,
                      ),
                      SizedBox(height: 14 * scale),
                      _TeacherStudyPurposeFilters(
                        selectedPurpose: _selectedPurpose,
                        scale: scale,
                        onSelected: _selectPurpose,
                      ),
                      SizedBox(height: 24 * scale),
                      if (_isLoadingExercises &&
                          _exercises.isEmpty &&
                          !_hasCompletedInitialLoad)
                        _TeacherStudyLoadingIndicator(scale: scale)
                      else if (_displayError != null && _exercises.isEmpty)
                        _TeacherErrorPanel(
                          scale: scale,
                          message: _displayError!,
                          onRetry: _refreshClassrooms,
                        )
                      else if (_classrooms.isEmpty)
                        Column(
                          children: [
                            _TeacherEmptyAssignmentsPanel(
                              message: context.getText(
                                AppKeys.teacherEmptyClassroomList,
                              ),
                            ),
                          ],
                        )
                      else if (_exercises.isEmpty)
                        Column(
                          children: [
                            _TeacherEmptyAssignmentsPanel(
                              message: _searchController.text.trim().isNotEmpty
                                  ? context.getText(
                                      AppKeys.teacherStudyNoResults,
                                    )
                                  : context.getText(
                                      _teacherExerciseCopy(
                                        _selectedPurpose,
                                      ).emptyKey,
                                    ),
                            ),
                          ],
                        )
                      else ...[
                        for (var index = 0;
                            index < visibleExercises.length;
                            index++) ...[
                          _TeacherStudyExerciseCard(
                            exercise: visibleExercises[index],
                            scale: scale,
                            onTap: () => _openExerciseDetail(
                              visibleExercises[index],
                            ),
                          ),
                          if (index != visibleExercises.length - 1)
                            SizedBox(height: 14 * scale),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
