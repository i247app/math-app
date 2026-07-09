import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/widgets/assessment_result/result_action_button.dart';

class AssessmentResultBottomBar extends StatelessWidget {
  const AssessmentResultBottomBar({
    super.key,
    required this.scale,
    required this.onTest,
    required this.onPractice,
  });

  final double scale;
  final VoidCallback onTest;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AssessmentResultActionButton(
          label: context.getText(AppKeys.assessmentUpper),
          background: AppColors.resultCoral,
          scale: scale,
          onTap: onTest,
        ),
        SizedBox(width: 40 * scale),
        AssessmentResultActionButton(
          label: context.getText(AppKeys.practiceUpper),
          icon: Icons.arrow_forward_rounded,
          background: AppColors.teal500,
          scale: scale,
          onTap: onPractice,
        ),
      ],
    );
  }
}
