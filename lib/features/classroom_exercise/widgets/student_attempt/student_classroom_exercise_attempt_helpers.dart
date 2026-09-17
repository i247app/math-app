import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/models/student_classroom_exercise_attempt_question.dart';

export 'package:numi/features/classroom_exercise/models/student_classroom_exercise_attempt_question.dart';

String? studentClassroomExerciseAttemptQuestionDataError(
  BuildContext context,
  List<StudentClassroomExerciseAttemptQuestion> questions,
) {
  if (questions.isEmpty) {
    return context.getText(AppKeys.studentClassroomExerciseNoQuestions);
  }
  if (questions.any((question) => question.answers.isEmpty)) {
    return context.getText(
      AppKeys.studentClassroomExerciseQuestionMissingAnswers,
    );
  }
  return null;
}
