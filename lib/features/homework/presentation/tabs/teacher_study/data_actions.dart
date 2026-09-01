part of '../teacher_study_tab.dart';

extension _TeacherStudyDataActions on _TeacherStudyTabState {
  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId = profileStableId(widget.activeProfile);
    _exerciseRequestId++;
    final isInitialProfileLoad =
        !_hasCompletedInitialLoad || profileId != _loadedProfileId;
    if (profileId == null) {
      _updateState(() {
        _loadedProfileId = null;
        _exercises = const <ClassroomExercise>[];
        _visibleExerciseCount = _TeacherStudyTabState._exercisePageSize;
        _error = context.readText(AppKeys.teacherMissingProfileId);
        _isLoadingExercises = false;
        _hasCompletedInitialLoad = true;
      });
      return;
    }

    _updateState(() {
      _loadedProfileId = profileId;
      _isLoadingExercises = true;
      if (isInitialProfileLoad) {
        _hasCompletedInitialLoad = false;
        _exercises = const <ClassroomExercise>[];
      }
      _visibleExerciseCount = _TeacherStudyTabState._exercisePageSize;
      _error = null;
    });

    final collection = await context.read<ClassroomCubit>().loadOwned(
      profileId,
      forceRefresh: forceRefresh,
    );
    if (!mounted || profileId != _loadedProfileId) {
      return;
    }

    final selectedStillExists =
        _selectedClassroomId == null ||
        collection.classrooms.any(
          (classroom) => classroom.stableId == _selectedClassroomId,
        );
    if (!selectedStillExists) {
      _selectedClassroomId = null;
    }
    if (collection.errorMessage != null && collection.classrooms.isEmpty) {
      _updateState(() {
        _exercises = const <ClassroomExercise>[];
        _visibleExerciseCount = _TeacherStudyTabState._exercisePageSize;
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
    final profileId = profileStableId(widget.activeProfile);
    if (profileId == null || _isLoadingClassrooms) {
      return;
    }

    final requestId = ++_exerciseRequestId;
    final classrooms = _selectedClassroomId == null
        ? _classrooms
        : _classrooms
              .where((classroom) => classroom.stableId == _selectedClassroomId)
              .toList(growable: false);
    final targets = classrooms
        .where((classroom) => classroom.stableId != null)
        .toList(growable: false);

    if (targets.isEmpty) {
      _updateState(() {
        _exercises = const <ClassroomExercise>[];
        _error = null;
        _isLoadingExercises = false;
        _hasCompletedInitialLoad = true;
      });
      return;
    }

    _updateState(() {
      _isLoadingExercises = true;
      _error = null;
      _visibleExerciseCount = _TeacherStudyTabState._exercisePageSize;
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
    exercises.sort(compareTeacherStudyExercises);

    _updateState(() {
      _exercises = deduplicateTeacherStudyExercises(exercises);
      _visibleExerciseCount = _TeacherStudyTabState._exercisePageSize;
      _error = exercises.isEmpty ? firstError : null;
      _isLoadingExercises = false;
      _hasCompletedInitialLoad = true;
    });
  }

  Future<TeacherStudyExerciseBatch> _loadExerciseBatch({
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
      return TeacherStudyExerciseBatch(exercises: exercises);
    } on ClassroomExerciseException catch (error) {
      return TeacherStudyExerciseBatch(
        error: error.message.trim().isEmpty ? fallbackError : error.message,
      );
    } catch (_) {
      return TeacherStudyExerciseBatch(error: fallbackError);
    }
  }
}
