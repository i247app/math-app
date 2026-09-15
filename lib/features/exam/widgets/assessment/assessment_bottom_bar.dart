import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_bottom_action_button.dart';

class AssessmentBottomBar extends StatelessWidget {
  const AssessmentBottomBar({
    super.key,
    required this.bottomInset,
    required this.canGoBack,
    required this.canContinue,
    required this.allQuestionsAnswered,
    required this.isSubmitting,
    this.isTransitioning = false,
    required this.onBack,
    required this.onExit,
    required this.onContinue,
  });
  static const double contentHeight = 84;

  final double bottomInset;
  final bool canGoBack;
  final bool canContinue;
  final bool allQuestionsAnswered;
  final bool isSubmitting;
  final bool isTransitioning;
  final VoidCallback onBack;
  final VoidCallback onExit;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final showSubmit = allQuestionsAnswered;
    return Container(
      height: contentHeight + bottomInset,
      padding: EdgeInsets.fromLTRB(14, 12, 14, 24 + bottomInset),
      color: colors.surface,
      child: Row(
        spacing: 48,
        children: [
          Expanded(
            child: AssessmentBottomActionButton(
              label: context.getText(
                canGoBack ? AppKeys.previousQuestionUpper : AppKeys.exitUpper,
              ),
              icon: canGoBack ? Icons.arrow_back_rounded : Icons.logout_rounded,
              background: canGoBack ? AppColors.brandOrange : AppColors.red700,
              foreground: colors.onAccent,
              disabledBackground: colors.disabledBackground,
              disabledForeground: colors.disabledForeground,
              labelFontSize: FontSize.normal,
              onTap: isSubmitting || isTransitioning
                  ? null
                  : canGoBack
                  ? onBack
                  : onExit,
            ),
          ),
          Expanded(
            child: AssessmentBottomActionButton(
              label: isSubmitting
                  ? context.getText(AppKeys.submittingUpper)
                  : showSubmit
                  ? context.getText(AppKeys.submitUpper)
                  : context.getText(AppKeys.continueUpper),
              icon: showSubmit
                  ? Icons.check_rounded
                  : Icons.arrow_forward_rounded,
              background: AppColors.brandTealSolid,
              foreground: colors.onBrand,
              labelFontSize: FontSize.normal,
              onTap: isSubmitting || isTransitioning || !canContinue
                  ? null
                  : onContinue,
            ),
          ),
        ],
      ),
    );
  }
}
