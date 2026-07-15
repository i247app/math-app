import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/application/quiz_review_controller.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_inline_error.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_mode_tabs.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_question_loading_section.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_result_question_list.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_retry_question_view.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_state_panel.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_stats_card.dart';

class QuizReviewContent extends StatelessWidget {
  const QuizReviewContent({
    super.key,
    required this.quiz,
    required this.selectedIndex,
    required this.mode,
    required this.allowRetry,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onModeSelected,
    required this.onQuestionSelected,
    required this.submittedAnswers,
    required this.retryAnswers,
    required this.onAnswerSelected,
    required this.onPrevious,
    required this.onNext,
  });

  final GeneratedQuiz quiz;
  final int selectedIndex;
  final QuizReviewMode mode;
  final bool allowRetry;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<QuizReviewMode> onModeSelected;
  final ValueChanged<int> onQuestionSelected;
  final Map<int, String> submittedAnswers;
  final Map<int, String> retryAnswers;
  final void Function(int questionNumber, String label) onAnswerSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final questions = quiz.questions;
    final safeIndex = questions.isEmpty
        ? 0
        : selectedIndex.clamp(0, questions.length - 1);
    final question = questions.isEmpty ? null : questions[safeIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading) const LinearProgressIndicator(color: AppColors.navy),
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            QuizReviewInlineError(message: errorMessage!, onRetry: onRetry),
            const SizedBox(height: 10),
          ],
          if (allowRetry) ...[
            QuizReviewModeTabs(selectedMode: mode, onSelected: onModeSelected),
            const SizedBox(height: 12),
          ],
          QuizReviewStatsCard(quiz: quiz),
          const SizedBox(height: 11),
          if (isLoading && question == null)
            const QuizReviewQuestionLoadingSection()
          else if (question == null)
            QuizReviewStatePanel(
              isLoading: false,
              message: context.getText(AppKeys.emptyQuizQuestions),
              onRetry: onRetry,
            )
          else if (!allowRetry || mode == QuizReviewMode.result)
            QuizReviewResultQuestionList(
              quiz: quiz,
              selectedAnswers: submittedAnswers,
            )
          else
            QuizReviewRetryQuestionView(
              questions: questions,
              selectedIndex: safeIndex,
              question: question,
              selectedAnswers: retryAnswers,
              onQuestionSelected: onQuestionSelected,
              onAnswerSelected: onAnswerSelected,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
        ],
      ),
    );
  }
}
