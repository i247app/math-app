import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';

void showTeacherHomeworkSoon(BuildContext context) {
  HapticFeedback.selectionClick();
  context.showInfoDialog(context.getText(AppKeys.teacherCreateAssignmentSoon));
}

String teacherExerciseTitle(BuildContext context, ClassroomExercise? exercise) {
  final title = exercise?.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise?.stableId;
  if (id != null) {
    return context.formatText(AppKeys.teacherAssignmentId, {'id': id});
  }
  return '';
}

String teacherExerciseQuestionCount(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final count = exercise?.numQuestions ?? exercise?.questions.length;
  if (count != null && count > 0) {
    return context.formatText(AppKeys.teacherAssignmentQuestionCountFormat, {
      'count': count,
    });
  }
  return '';
}

String teacherExerciseDueDate(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  return teacherExerciseDateTimeLabel(exercise?.endDate) ?? '';
}

String? teacherExerciseDateTimeLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return '${twoDigits(local.hour)}:${twoDigits(local.minute)} '
      '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year}';
}

TeacherExerciseDateParts teacherExerciseDateParts(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return const TeacherExerciseDateParts(day: '23', month: 'TH10');
  }
  final local = parsed.toLocal();
  return TeacherExerciseDateParts(
    day: twoDigits(local.day),
    month: 'TH${twoDigits(local.month)}',
  );
}

String twoDigits(int value) => value.toString().padLeft(2, '0');

class TeacherExerciseDateParts {
  const TeacherExerciseDateParts({required this.day, required this.month});

  final String day;
  final String month;
}
