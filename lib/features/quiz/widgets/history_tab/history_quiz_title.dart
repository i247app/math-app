import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/helpers/history_quiz_purpose.dart';

String historyQuizTitle(BuildContext context, GeneratedQuiz quiz) {
  if (quiz.title != null && quiz.title!.trim().isNotEmpty) {
    return quiz.title!;
  }

  final grade = quiz.grading?.aiDetectGrade?.trim();
  final suffix = grade != null && grade.isNotEmpty ? ' $grade' : '';
  final type = historyQuizPurpose(quiz);

  if (type == 'ASSESSMENT') {
    return '${context.getText(AppKeys.mathAssessment)}$suffix';
  }
  if (type == 'PRACTICE') {
    return '${context.getText(AppKeys.mathPractice)}$suffix';
  }
  return '${context.getText(AppKeys.mathReview)}$suffix';
}
