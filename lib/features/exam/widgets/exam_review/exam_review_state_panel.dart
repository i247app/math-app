import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_card.dart';

class ExamReviewStatePanel extends StatelessWidget {
  const ExamReviewStatePanel({
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
    final colors = context.themeColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ExamReviewCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 14,
            children: [
              if (isLoading)
                CircularProgressIndicator(color: colors.info)
              else ...[
                Icon(Icons.assignment_outlined, color: colors.info, size: 42),
                Text(
                  message ?? context.getText(AppKeys.examDetailErrorTitle),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: FontSize.compact,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: TextButton(
                    onPressed: onRetry,
                    child: Text(context.getText(AppKeys.retry)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
