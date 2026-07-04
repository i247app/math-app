import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment_result/assessment_result_style.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment_result/result_action_button.dart';

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
          background: AssessmentResultStyle.coral,
          scale: scale,
          onTap: onTest,
        ),
        SizedBox(width: 40 * scale),
        AssessmentResultActionButton(
          label: context.getText(AppKeys.practiceUpper),
          icon: Icons.arrow_forward_rounded,
          background: AssessmentResultStyle.headerTeal,
          scale: scale,
          onTap: onPractice,
        ),
      ],
    );
  }
}
