import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/presentation/screens/quiz_review_entry_screen.dart';

void historyOpenQuizReview(BuildContext context, GeneratedQuiz quiz) {
  final quizId = quiz.quizId ?? quiz.id;
  if (quizId == null) {
    context.showErrorDialog(context.readText(AppKeys.missingQuizId));
    return;
  }

  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => QuizReviewScreen(quizId: quizId, initialQuiz: quiz),
    ),
  );
}
