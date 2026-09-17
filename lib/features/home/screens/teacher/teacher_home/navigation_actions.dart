part of '../teacher_home_tab.dart';

extension _TeacherHomeNavigationActions on _TeacherRoleTabState {
  Future<void> _openCreateClass() async {
    HapticFeedback.lightImpact();
    final previousClassroomIds = _classrooms
        .map((classroom) => classroom.stableId)
        .whereType<int>()
        .toSet();
    final createdClassroom = await widget.onCreateClass?.call(context);
    if (createdClassroom != null) {
      await _refreshClassrooms();
      if (!mounted) {
        return;
      }
      final classroom = _findCreatedClassroom(
        createdClassroom,
        previousClassroomIds,
      );
      if (classroom != null) {
        await _openClassDetail(classroom, initiallyExpanded: true);
      }
    }
  }

  Future<void> _openProfileCompletion() async {
    HapticFeedback.selectionClick();
    await widget.onCompleteProfile();
  }

  Future<void> _handleClassCreateAction() async {
    if (!isTeacherProfileComplete(widget.activeProfile)) {
      await _openProfileCompletion();
      return;
    }

    await _openCreateClass();
  }

  ClassroomModel? _findCreatedClassroom(
    ClassroomModel createdClassroom,
    Set<int> previousClassroomIds,
  ) {
    final createdId = createdClassroom.stableId;
    if (createdId != null) {
      for (final classroom in _classrooms) {
        if (classroom.stableId == createdId) {
          return classroom;
        }
      }
      return createdClassroom;
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
    final profileId = profileStableId(widget.activeProfile);
    if (classroomId == null || profileId == null) {
      _showError(context.readText(AppKeys.teacherClassOpenFailed));
      return;
    }

    HapticFeedback.selectionClick();
    await widget.onOpenClassDetail?.call(context, classroom, initiallyExpanded);
  }

  void _openAssignmentDetail(ClassroomExercise exercise) {
    final exerciseId = exercise.stableId;
    final profileId = profileStableId(widget.activeProfile);
    if (exerciseId == null || profileId == null) {
      showTeacherClassroomExerciseSoon(context);
      return;
    }

    HapticFeedback.selectionClick();
    widget.onOpenAssignmentDetail?.call(context, exercise);
  }

  void _showError(String message) {
    context.showErrorDialog(message);
  }
}
