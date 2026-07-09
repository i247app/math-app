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

bool showStudentHomeworkNotOpenSnackIfNeeded(
  BuildContext context,
  ClassroomExercise exercise,
) {
  if (!studentHomeworkIsNotOpen(exercise)) {
    return false;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.studentHomeworkNotOpen)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  return true;
}
