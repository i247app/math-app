import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_labeled_value.dart';

List<TeacherAssignmentLabeledValue> exerciseInfoRows(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final rows = <TeacherAssignmentLabeledValue>[];
  final chapter = exercise?.chapterName?.trim();
  final lesson = exercise?.lessonName?.trim();
  final description = exercise?.description?.trim();

  if (chapter != null && chapter.isNotEmpty) {
    rows.add(
      TeacherAssignmentLabeledValue(
        context.getText(AppKeys.teacherAssignmentChapterLabel),
        chapter,
      ),
    );
  }
  if (lesson != null && lesson.isNotEmpty) {
    rows.add(
      TeacherAssignmentLabeledValue(
        context.getText(AppKeys.teacherAssignmentLessonLabel),
        lesson,
      ),
    );
  }
  if (description != null && description.isNotEmpty) {
    rows.add(
      TeacherAssignmentLabeledValue(
        context.getText(AppKeys.teacherAssignmentDescriptionLabel),
        description,
      ),
    );
  }

  return rows;
}

String teacherExerciseClassLabel(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final classroomId = exercise?.classroomId;
  if (classroomId == null) {
    return '';
  }
  return context.formatText(AppKeys.teacherAssignmentId, {'id': classroomId});
}

String? normalizeExerciseVisibility(String? value) {
  final normalized = value?.trim().toUpperCase();
  if (normalized == 'PUBLIC' || normalized == 'PRIVATE') {
    return normalized;
  }
  return null;
}

String answerLetter(int index) {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  if (index < 0 || index >= letters.length) {
    return '?';
  }
  return letters[index];
}

bool isCorrectAnswer(
  ClassroomExerciseQuestion? question,
  String answer,
  int index,
) {
  final correct = question?.correctAnswer?.trim();
  if (correct == null || correct.isEmpty) {
    return false;
  }
  return correct == answer.trim() || correct == answerLetter(index);
}
