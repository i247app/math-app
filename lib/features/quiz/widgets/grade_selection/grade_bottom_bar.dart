import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/widgets/grade_selection/pill_action_button.dart';

class GradeBottomBar extends StatelessWidget {
  const GradeBottomBar({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return ColoredBox(
      color: colors.pageBackground,
      child: SizedBox(
        height: 168,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 224),
              child: PillActionButton(
                label: context.getText(AppKeys.continueLabel),
                background: AppColors.coral500,
                foreground: Colors.white,
                onPressed: onContinue,
                height: 56,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
