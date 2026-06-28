part of '../../presentation/teacher_classroom_screens.dart';

bool _isStudentProfile(StudentProfile profile) {
  final role = profile.role?.trim().toUpperCase();
  return role == null || role.isEmpty || role == 'STUDENT';
}

String? _studentSearchSubtitle(BuildContext context, StudentProfile profile) {
  final studentId = profile.studentId?.trim();
  if (studentId != null && studentId.isNotEmpty) {
    return studentId;
  }

  final grade = profile.grade?.label?.trim();
  if (grade != null && grade.isNotEmpty) {
    return grade;
  }

  return null;
}

String _classroomMemberName(BuildContext context, ClassroomStudent member) {
  return _nonEmpty(member.name) ??
      context.getText(AppKeys.teacherStudentFallback);
}

String _classroomMemberStatus(BuildContext context, ClassroomStudent member) {
  final status = _nonEmpty(member.status);
  if (status == null || status.toUpperCase() == 'ACTIVE') {
    return context.getText(AppKeys.teacherJustJoined);
  }
  return status;
}
