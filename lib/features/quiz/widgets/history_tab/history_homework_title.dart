import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';

String historyHomeworkTitle(BuildContext context, ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise.stableId;
  if (id != null) {
    return '${context.getText(AppKeys.studentHomework)} #$id';
  }
  return context.getText(AppKeys.studentHomework);
}
