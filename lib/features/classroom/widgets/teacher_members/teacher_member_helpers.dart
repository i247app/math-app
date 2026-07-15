import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_shared_helpers.dart';

bool isStudentProfile(StudentProfile profile) {
  final role = profile.role?.trim().toUpperCase();
  return role == null || role.isEmpty || role == 'STUDENT';
}

String? studentSearchSubtitle(BuildContext context, StudentProfile profile) {
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

String classroomMemberName(BuildContext context, ClassroomStudent member) {
  return nonEmpty(member.name) ??
      context.getText(AppKeys.teacherStudentFallback);
}

String classroomMemberStatus(BuildContext context, ClassroomStudent member) {
  final status = nonEmpty(member.status);
  if (status == null || status.toUpperCase() == 'ACTIVE') {
    return context.getText(AppKeys.teacherJustJoined);
  }
  return status;
}
