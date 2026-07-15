import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';

bool studentHomeworkIsNotOpen(ClassroomExercise exercise) {
  final startDate = DateTime.tryParse(exercise.startDate?.trim() ?? '');
  if (startDate == null) {
    return false;
  }
  return startDate.toLocal().isAfter(DateTime.now());
}

bool showStudentHomeworkNotOpenDialogIfNeeded(
  BuildContext context,
  ClassroomExercise exercise,
) {
  if (!studentHomeworkIsNotOpen(exercise)) {
    return false;
  }
  context.showErrorDialog(context.getText(AppKeys.studentHomeworkNotOpen));
  return true;
}
