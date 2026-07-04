import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/features/homework/widgets/student_list/student_homework_filter.dart';

String studentHomeworkTitle(ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise.stableId;
  return id == null ? '' : 'ID: $id';
}

String studentHomeworkQuestionCount(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final count = exercise.numQuestions ?? exercise.questions.length;
  if (count > 0) {
    return context.formatText(AppKeys.teacherAssignmentQuestionCountFormat, {
      'count': count,
    });
  }
  return '';
}

String studentHomeworkDueDate(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final date = _studentHomeworkDateLabel(exercise.endDate);
  if (date == null) {
    return '';
  }
  return '${context.getText(AppKeys.teacherAssignmentDueLabel)}: $date';
}

String studentHomeworkCreatedDate(ClassroomExercise exercise) {
  return _studentHomeworkDateLabel(exercise.createDt) ?? '';
}

String? _studentHomeworkDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return '${_studentHomeworkTwoDigits(local.hour)}:'
      '${_studentHomeworkTwoDigits(local.minute)} '
      '${_studentHomeworkTwoDigits(local.day)}/'
      '${_studentHomeworkTwoDigits(local.month)}/${local.year}';
}

String _studentHomeworkTwoDigits(int value) => value.toString().padLeft(2, '0');

List<ClassroomExercise> filteredStudentHomeworkExercises(
  List<ClassroomExercise> exercises,
  StudentHomeworkFilter filter,
) {
  return exercises
      .where((exercise) {
        final submitted = studentHomeworkIsSubmitted(exercise);
        final overdue = studentHomeworkIsOverdue(exercise);
        return switch (filter) {
          StudentHomeworkFilter.notSubmitted => !submitted && !overdue,
          StudentHomeworkFilter.submitted => submitted,
          StudentHomeworkFilter.overdue => overdue,
        };
      })
      .toList(growable: false);
}

bool studentHomeworkIsSubmitted(ClassroomExercise exercise) {
  return exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}

bool studentHomeworkIsOverdue(ClassroomExercise exercise) {
  if (studentHomeworkIsSubmitted(exercise)) {
    return false;
  }
  final parsed = DateTime.tryParse(exercise.endDate?.trim() ?? '');
  if (parsed == null) {
    return false;
  }
  return parsed.toLocal().isBefore(DateTime.now());
}
