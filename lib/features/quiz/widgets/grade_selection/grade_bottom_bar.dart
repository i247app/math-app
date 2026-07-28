import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/widgets/grade_selection/pill_action_button.dart';

class GradeBottomBar extends StatelessWidget {
  const GradeBottomBar({
    super.key,
    required this.onSkip,
    required this.onContinue,
  });
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
        child: Row(
          spacing: 20,
          children: [
            Expanded(
              flex: 9,
              child: PillActionButton(
                label: context.getText(AppKeys.skipUpper),
                background: AppColors.brandOrangeSolid,
                foreground: Colors.white,
                onPressed: onSkip,
              ),
            ),
            Expanded(
              flex: 10,
              child: PillActionButton(
                label: context.getText(AppKeys.continueUpper),
                background: AppColors.brandTealSolid,
                foreground: Colors.white,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
