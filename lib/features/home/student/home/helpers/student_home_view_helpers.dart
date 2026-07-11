import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:flutter/material.dart';

DateTime studentModeDate(String? value) {
  return DateTime.tryParse(value?.trim() ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String studentModeHomeworkTitle(ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  return AppStrings.current(AppKeys.studentHomeworkReviewLabel);
}

String studentModeHomeworkCreatedDate(ClassroomExercise exercise) {
  return _studentModeDateLabel(exercise.createDt ?? exercise.startDate) ?? '';
}

String studentModeHomeworkDueDate(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final date = _studentModeDateLabel(exercise.endDate);
  if (date == null) {
    return context.getText(AppKeys.teacherAssignmentDueLabel);
  }
  return '${context.getText(AppKeys.teacherAssignmentDueLabel)}: $date';
}

String? _studentModeDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(local.hour)}:${twoDigits(local.minute)} '
      '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year}';
}

String studentModePurposeLabel(String purpose) {
  final normalized = purpose.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return AppStrings.current(AppKeys.studentHomeworkPurposeQuiz);
  }
  return AppStrings.current(AppKeys.studentHomeworkPurposeHomework);
}
