import 'package:flutter/widgets.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/models/classroom.dart';

String classroomDisplayName(BuildContext context, ClassroomModel classroom) {
  final name = classroom.name?.trim();
  return name?.isNotEmpty == true
      ? name!
      : context.getText(AppKeys.teacherClassFallback);
}

String classroomTeacherName(
  BuildContext context,
  ClassroomModel classroom, {
  bool fallbackToSchool = false,
}) {
  final teacherName = classroom.teacherName?.trim();
  if (teacherName?.isNotEmpty == true) return teacherName!;

  final schoolName = classroom.schoolName?.trim();
  if (fallbackToSchool && schoolName?.isNotEmpty == true) return schoolName!;

  return context.getText(AppKeys.teacherFallback);
}
