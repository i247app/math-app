import 'dart:ui';

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
    required this.canGoBack,
    required this.canContinue,
    required this.isLastQuestion,
    required this.isSubmitting,
    required this.onBack,
    required this.onContinue,
  });
  final bool canGoBack;
  final bool canContinue;
  final bool isLastQuestion;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 97,
          padding: const EdgeInsets.fromLTRB(14, 25, 14, 24),
          decoration: BoxDecoration(
            color: colors.elevatedSurface.withValues(alpha: 0.90),
            border: Border(
              top: BorderSide(color: colors.border.withValues(alpha: 0.50)),
            ),
          ),
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
                      : isLastQuestion
                      ? context.getText(AppKeys.submitUpper)
                      : context.getText(AppKeys.continueUpper),
                  icon: isLastQuestion
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  background: AppColors.brandTealSolid,
                  foreground: colors.onBrand,
                  labelFontSize: FontSize.normal,
                  onTap: isSubmitting || (isLastQuestion && !canContinue)
                      ? null
                      : onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
