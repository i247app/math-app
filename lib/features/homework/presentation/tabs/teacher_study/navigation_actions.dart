part of '../teacher_study_tab.dart';

extension _TeacherStudyNavigationActions on _TeacherStudyTabState {
  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    if (_visibleExerciseCount != _TeacherStudyTabState._exercisePageSize) {
      _updateState(
        () => _visibleExerciseCount = _TeacherStudyTabState._exercisePageSize,
      );
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), _loadExercises);
  }

  void _selectClassroom(int? classroomId) {
    if (_selectedClassroomId == classroomId) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      _selectedClassroomId = classroomId;
      _visibleExerciseCount = _TeacherStudyTabState._exercisePageSize;
    });
    _loadExercises();
  }

  void _selectPurpose(String purpose) {
    if (_selectedPurpose == purpose) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      _selectedPurpose = purpose;
      _visibleExerciseCount = _TeacherStudyTabState._exercisePageSize;
    });
    _loadExercises();
  }

  void _showMoreExercises() {
    if (_visibleExerciseCount >= _exercises.length) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      _visibleExerciseCount =
          (_visibleExerciseCount + _TeacherStudyTabState._exercisePageSize)
              .clamp(0, _exercises.length);
    });
  }

  Future<void> _openCreateExercise() async {
    final profileId = profileStableId(widget.activeProfile);
    final classroom = _createClassroomSelection;
    final classroomId = classroom?.stableId;
    if (profileId == null || classroom == null || classroomId == null) {
      _showError(context.readText(AppKeys.teacherNoOptions));
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
    final profileId = profileStableId(widget.activeProfile);
    if (exerciseId == null || profileId == null) {
      showTeacherHomeworkSoon(context);
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

  void _showError(String message) {
    context.showErrorDialog(message);
  }
}
