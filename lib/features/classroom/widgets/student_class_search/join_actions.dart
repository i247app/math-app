part of '../student_class_search_content.dart';

extension _StudentClassJoinActions on _StudentClassSearchContentState {
  Future<void> _joinClassroom(ClassroomModel classroom) async {
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
        profileId: widget.profileId,
        classroomCode: code,
      );
      if (!mounted) {
        return;
      }
      widget.onJoinRequested?.call();
      context.read<ClassroomCubit>().invalidateJoined(widget.profileId);
      await _search(null, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorDialog(
        error is ClassroomException
            ? error.message
            : context.readText(AppKeys.studentJoinClassFailed),
      );
    } finally {
      if (mounted) {
        _updateState(() => _joiningClassroomId = null);
      }
    }
  }
}
