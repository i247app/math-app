import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_nav_button.dart';

class ExamReviewQuestionNavigationBar extends StatelessWidget {
  const ExamReviewQuestionNavigationBar({
    super.key,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        spacing: 28,
        children: [
          Expanded(
            child: ExamReviewNavButton(
              label: context.getText(AppKeys.previous),
              icon: Icons.chevron_left_rounded,
              filled: false,
              enabled: canGoPrevious,
              onTap: onPrevious,
            ),
          ),
          Expanded(
            child: ExamReviewNavButton(
              label: context.getText(AppKeys.next),
              icon: Icons.chevron_right_rounded,
              filled: true,
              enabled: canGoNext,
              onTap: onNext,
              iconAfter: true,
            ),
          ),
        ],
      ),
    );
  }
}
