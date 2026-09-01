part of '../teacher_create_homework_screen.dart';

extension _TeacherCreateHomeworkFormActions
    on _TeacherCreateHomeworkScreenState {
  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    if (!_validateCreateHomeworkForm()) {
      return;
    }

    HapticFeedback.selectionClick();
    _updateState(() => _isSubmitting = true);
    try {
      await _exerciseService.createExercise(
        profileId: widget.profileId,
        classroomId: _selectedClassroomId,
        programId: _selectedProgramId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        numQuestions: _selectedQuestionCount,
        chapterName: trimOrDefault(
          _chapterController.text,
          context.readText(AppKeys.teacherAssignmentDefaultChapter),
        ),
        lessonName: trimOrDefault(
          _lessonController.text,
          context.readText(AppKeys.teacherAssignmentDefaultLesson),
        ),
        visibility: _visibility,
        startDate: exerciseApiDate(_startDate!),
        endDate: exerciseApiDate(_endDate!),
        purpose: widget.purpose,
      );
      if (!mounted) {
        return;
      }
      await _exitController.exitWithResult(true);
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      _showError(
        error.message.trim().isEmpty
            ? context.readText(
                teacherExerciseCopy(widget.purpose).createFailedKey,
              )
            : error.message,
      );
    } finally {
      if (mounted) {
        _updateState(() => _isSubmitting = false);
      }
    }
  }

  int get _selectedClassroomId =>
      _selectedClassroom?.stableId ?? widget.classroomId;

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _markDraftDirty() {
    if (!_isDraftDirty && mounted) {
      _updateState(() => _isDraftDirty = true);
    }
  }

  void _handleTitleChanged() {
    _markDraftDirty();
    if (_titleErrorText != null && _titleController.text.trim().isNotEmpty) {
      _updateState(() => _titleErrorText = null);
    }
  }

  bool _validateCreateHomeworkForm() {
    if (_titleController.text.trim().isEmpty) {
      _updateState(() {
        _titleErrorText = context.readText(
          teacherExerciseCopy(widget.purpose).titleRequiredKey,
        );
      });
      _titleFocusNode.requestFocus();
      return false;
    }

    final now = DateTime.now();
    if (_selectedProgramId == null) {
      _showError(context.readText(AppKeys.teacherAssignmentProgramRequired));
      return false;
    }
    if (_startDate == null) {
      _showError(context.readText(AppKeys.teacherAssignmentStartDateRequired));
      return false;
    }
    if (_endDate == null) {
      _showError(context.readText(AppKeys.teacherAssignmentEndDateRequired));
      return false;
    }
    if (!_startDate!.isAfter(now) || !_endDate!.isAfter(now)) {
      _showError(context.readText(AppKeys.teacherAssignmentFutureDateRequired));
      return false;
    }
    if (!_endDate!.isAfter(_startDate!)) {
      _showError(context.readText(AppKeys.teacherAssignmentEndAfterStart));
      return false;
    }
    return true;
  }
}
