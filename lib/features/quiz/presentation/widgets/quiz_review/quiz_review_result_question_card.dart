import 'package:flutter/material.dart';

import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_answer_list.dart';
import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_correct_answer_label.dart';
import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_question_badge.dart';
import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_question_status.dart';

class QuizReviewResultQuestionCard extends StatelessWidget {
  const QuizReviewResultQuestionCard({
    super.key,
    required this.question,
    required this.selectedLabel,
  });

  final QuizQuestion question;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    final correctLabel = quizReviewCorrectAnswerLabel(question);
    final isCorrect = selectedLabel != null && selectedLabel == correctLabel;
    final accent = isCorrect ? AppColors.teal600 : AppColors.red;
    final colors = context.themeColors;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 18,
                  children: [
                    Row(
                      children: [
                        QuizReviewQuestionBadge(
                          number: question.questionNumber,
                          color: isCorrect
                              ? AppColors.aquaMist
                              : const Color(0xFFFFD9DC),
                          textColor: isCorrect
                              ? AppColors.teal600
                              : AppColors.red,
                        ),
                        const Spacer(),
                        QuizReviewQuestionStatus(isCorrect: isCorrect),
                      ],
                    ),
                    Text(
                      question.questionName,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: 0,
                      ),
                    ),
                    QuizReviewAnswerList(
                      question: question,
                      selectedLabel: selectedLabel,
                      showCorrectAnswer: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
