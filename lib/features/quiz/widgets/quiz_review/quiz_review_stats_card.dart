import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_card.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_computed_correct_count.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_stat_item.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_time_label.dart';

class QuizReviewStatsCard extends StatelessWidget {
  const QuizReviewStatsCard({super.key, required this.quiz});

  final GeneratedQuiz quiz;

  @override
  Widget build(BuildContext context) {
    final total = quiz.grading?.totalQuestions ?? quiz.questions.length;
    final correct =
        quiz.grading?.correctNumber ?? quizReviewComputedCorrectCount(quiz);
    final wrong = total > correct ? total - correct : 0;
    final time = quizReviewTimeLabel(quiz);

    return QuizReviewCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          QuizReviewStatItem(
            icon: Icons.quiz_outlined,
            iconColor: AppColors.teal600,
            iconBackground: const Color(0xFFDDF1FF),
            valueColor: AppColors.teal600,
            value: '$total',
            label: context.getText(AppKeys.totalQuestions),
          ),
          QuizReviewStatItem(
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.teal600,
            iconBackground: AppColors.aquaMist,
            valueColor: AppColors.teal600,
            value: '$correct',
            label: context.getText(AppKeys.correct),
          ),
          QuizReviewStatItem(
            icon: Icons.cancel_outlined,
            iconColor: AppColors.red,
            iconBackground: const Color(0xFFFFDCDD),
            valueColor: AppColors.red,
            value: '$wrong',
            label: context.getText(AppKeys.incorrect),
          ),
          QuizReviewStatItem(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.orange,
            iconBackground: const Color(0xFFFFEAD6),
            valueColor: AppColors.orange,
            value: time,
            label: context.getText(AppKeys.time),
          ),
        ],
      ),
    );
  }
}
