import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/presentation/widgets/assessment_result/result_action_button.dart';

class AssessmentResultBottomBar extends StatelessWidget {
  const AssessmentResultBottomBar({
    super.key,
    required this.onTest,
    required this.onPractice,
  });
  final VoidCallback onTest;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 40,
      children: [
        Expanded(
          child: AssessmentResultActionButton(
            label: context.getText(AppKeys.assessmentUpper),
            background: AppColors.resultCoral,
            onTap: onTest,
          ),
        ),
        Expanded(
          child: AssessmentResultActionButton(
            label: context.getText(AppKeys.practiceUpper),
            icon: Icons.arrow_forward_rounded,
            background: AppColors.teal500,
            onTap: onPractice,
          ),
        ),
      ],
    );
  }
}
