import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/application/read_models/student_homework_attempt_question.dart';

export 'package:numi/features/homework/application/read_models/student_homework_attempt_question.dart';

String? studentHomeworkAttemptQuestionDataError(
  BuildContext context,
  List<StudentHomeworkAttemptQuestion> questions,
) {
  if (questions.isEmpty) {
    return context.getText(AppKeys.studentHomeworkNoQuestions);
  }
  if (questions.any((question) => question.answers.isEmpty)) {
    return context.getText(AppKeys.studentHomeworkQuestionMissingAnswers);
  }
  return null;
}
