import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_bottom_action_button.dart';

class AssessmentBottomBar extends StatelessWidget {
  const AssessmentBottomBar({
    super.key,
    required this.bottomInset,
    required this.canGoBack,
    required this.allQuestionsAnswered,
    required this.isSubmitting,
    required this.onBack,
    required this.onContinue,
  });
  static const double contentHeight = 97;

  final double bottomInset;
  final bool canGoBack;
  final bool allQuestionsAnswered;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final showSubmit = allQuestionsAnswered;
    return Container(
      height: contentHeight + bottomInset,
      padding: EdgeInsets.fromLTRB(14, 25, 14, 24 + bottomInset),
      color: colors.surface,
      child: Row(
        spacing: 48,
        children: [
          Expanded(
            child: AssessmentBottomActionButton(
              label: context.getText(AppKeys.previousQuestionUpper),
              icon: Icons.arrow_back_rounded,
              background: AppColors.brandOrange,
              foreground: colors.onAccent,
              disabledBackground: AppColors.brandOrange,
              disabledForeground: colors.onAccent,
              labelFontSize: FontSize.normal,
              onTap: canGoBack && !isSubmitting ? onBack : null,
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
              onTap: isSubmitting ? null : onContinue,
            ),
          ),
        ],
      ),
    );
  }
}
