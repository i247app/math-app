import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/quiz/application/controllers/quiz_review_controller.dart';
import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_mode_tab_button.dart';

class QuizReviewModeTabs extends StatelessWidget {
  const QuizReviewModeTabs({
    super.key,
    required this.selectedMode,
    required this.onSelected,
  });

  final QuizReviewMode selectedMode;
  final ValueChanged<QuizReviewMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: QuizReviewModeTabButton(
              label: context.getText(AppKeys.testAgain),
              selected: selectedMode == QuizReviewMode.retry,
              onTap: () => onSelected(QuizReviewMode.retry),
            ),
          ),
          Expanded(
            child: QuizReviewModeTabButton(
              label: context.getText(AppKeys.viewResult),
              selected: selectedMode == QuizReviewMode.result,
              onTap: () => onSelected(QuizReviewMode.result),
            ),
          ),
        ],
      ),
    );
  }
}
