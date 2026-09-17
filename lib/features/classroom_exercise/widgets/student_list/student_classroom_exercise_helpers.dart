import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_filter.dart';

String studentClassroomExerciseTitle(ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise.stableId;
  return id == null ? '' : 'ID: $id';
}

String studentClassroomExerciseQuestionCount(
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

String studentClassroomExerciseDueDate(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final date = _studentClassroomExerciseDateLabel(exercise.endDate);
  if (date == null) {
    return '';
  }
  return '${context.getText(AppKeys.teacherAssignmentDueLabel)}: $date';
}

String studentClassroomExerciseCreatedDate(ClassroomExercise exercise) {
  return _studentClassroomExerciseDateLabel(exercise.createDt) ?? '';
}

String? _studentClassroomExerciseDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return '${_studentClassroomExerciseTwoDigits(local.hour)}:'
      '${_studentClassroomExerciseTwoDigits(local.minute)} '
      '${_studentClassroomExerciseTwoDigits(local.day)}/'
      '${_studentClassroomExerciseTwoDigits(local.month)}/${local.year}';
}

String _studentClassroomExerciseTwoDigits(int value) =>
    value.toString().padLeft(2, '0');

List<ClassroomExercise> filteredStudentClassroomExerciseExercises(
  List<ClassroomExercise> exercises,
  StudentClassroomExerciseFilter filter,
) {
  return exercises
      .where((exercise) {
        final submitted = studentClassroomExerciseIsSubmitted(exercise);
        final overdue = studentClassroomExerciseIsOverdue(exercise);
        return switch (filter) {
          StudentClassroomExerciseFilter.notSubmitted => !submitted && !overdue,
          StudentClassroomExerciseFilter.submitted => submitted,
          StudentClassroomExerciseFilter.overdue => overdue,
        };
      })
      .toList(growable: false);
}

bool studentClassroomExerciseIsSubmitted(ClassroomExercise exercise) {
  return exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}

bool studentClassroomExerciseIsOverdue(ClassroomExercise exercise) {
  if (studentClassroomExerciseIsSubmitted(exercise)) {
    return false;
  }
  final parsed = DateTime.tryParse(exercise.endDate?.trim() ?? '');
  if (parsed == null) {
    return false;
  }
  return parsed.toLocal().isBefore(DateTime.now());
}
