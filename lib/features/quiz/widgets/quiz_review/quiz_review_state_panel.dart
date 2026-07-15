import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_card.dart';

class QuizReviewStatePanel extends StatelessWidget {
  const QuizReviewStatePanel({
    super.key,
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: QuizReviewCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const CircularProgressIndicator(color: AppColors.navy)
              else ...[
                const Icon(
                  Icons.quiz_outlined,
                  color: AppColors.navy,
                  size: 42,
                ),
                const SizedBox(height: 14),
                Text(
                  message ?? context.getText(AppKeys.quizDetailErrorTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onRetry,
                  child: Text(context.getText(AppKeys.retry)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
