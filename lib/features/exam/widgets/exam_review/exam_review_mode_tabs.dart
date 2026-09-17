import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/controllers/exam_review_controller.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_mode_tab_button.dart';

class ExamReviewModeTabs extends StatelessWidget {
  const ExamReviewModeTabs({
    super.key,
    required this.selectedMode,
    required this.onSelected,
  });

  final ExamReviewMode selectedMode;
  final ValueChanged<ExamReviewMode> onSelected;

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
            child: ExamReviewModeTabButton(
              label: context.getText(AppKeys.testAgain),
              selected: selectedMode == ExamReviewMode.retry,
              onTap: () => onSelected(ExamReviewMode.retry),
            ),
          ),
          Expanded(
            child: ExamReviewModeTabButton(
              label: context.getText(AppKeys.viewResult),
              selected: selectedMode == ExamReviewMode.result,
              onTap: () => onSelected(ExamReviewMode.result),
            ),
          ),
        ],
      ),
    );
  }
}
