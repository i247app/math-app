import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

bool studentClassroomExerciseIsNotOpen(ClassroomExercise exercise) {
  final startDate = DateTime.tryParse(exercise.startDate?.trim() ?? '');
  if (startDate == null) {
    return false;
  }
  return startDate.toLocal().isAfter(DateTime.now());
}

bool showStudentClassroomExerciseNotOpenDialogIfNeeded(
  BuildContext context,
  ClassroomExercise exercise,
) {
  if (!studentClassroomExerciseIsNotOpen(exercise)) {
    return false;
  }
  context.showErrorDialog(
    context.getText(AppKeys.studentClassroomExerciseNotOpen),
  );
  return true;
}
