part of '../student_class_search_content.dart';

extension _StudentClassJoinActions on _StudentClassSearchContentState {
  Future<void> _joinClassroom(ClassroomModel classroom) async {
    if (_joiningClassroomId != null) return;
    final requestId = ++_joinRequestId;
    final scope = SessionCacheScope.current;
    final profileId = widget.profileId;
    bool current() => mounted && requestId == _joinRequestId && scope.isCurrent;
    final relationship = classroom.relationshipStatus;
    if (relationship != ClassroomRelationship.none) {
      HapticFeedback.selectionClick();
      context.showInfoDialog(
        relationship == ClassroomRelationship.member
            ? context.readText(AppKeys.studentAlreadyJoinedClass)
            : context.readText(AppKeys.studentClassJoinRequestPending),
      );
      return;
    }

    final code = classroomCode(classroom);
    if (code == null) {
      context.showErrorDialog(
        context.readText(AppKeys.studentClassMissingCode),
      );
      return;
    }

    HapticFeedback.lightImpact();
    _updateState(() => _joiningClassroomId = classroom.stableId ?? -1);
    try {
      await _classroomService.joinClassroomByCode(
        profileId: profileId,
        classroomCode: code,
      );
      if (!mounted || !current()) {
        return;
      }
      context.read<ClassroomCubit>().invalidateJoined(profileId);
      widget.onJoinRequested?.call();
      await _search(null, true);
    } catch (error) {
      if (!mounted || !current()) {
        return;
      }
      context.showErrorDialog(
        error is ClassroomException
            ? error.message
            : context.readText(AppKeys.studentJoinClassFailed),
      );
    } finally {
      if (current()) {
        _updateState(() => _joiningClassroomId = null);
      }
    }
  }
}
