import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/presentation/widgets/student_attempt/student_homework_attempt_bottom_action_button.dart';

class StudentHomeworkAttemptBottomBar extends StatelessWidget {
  const StudentHomeworkAttemptBottomBar({
    super.key,
    required this.bottomInset,
    required this.canGoBack,
    required this.isLastQuestion,
    required this.isSubmitting,
    required this.onBack,
    required this.onContinue,
  });
  static const double contentHeight = 97;

  final double bottomInset;
  final bool canGoBack;
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
          height: contentHeight + bottomInset,
          padding: EdgeInsets.fromLTRB(24, 25, 24, 24 + bottomInset),
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
                child: StudentHomeworkAttemptBottomActionButton(
                  label: context.getText(AppKeys.previousQuestionUpper),
                  icon: Icons.arrow_back_rounded,
                  background: AppColors.peachStrong.withValues(alpha: 0.50),
                  foreground: AppColors.rust,
                  onTap: canGoBack && !isSubmitting ? onBack : null,
                ),
              ),
              Expanded(
                child: StudentHomeworkAttemptBottomActionButton(
                  label: isSubmitting
                      ? context.getText(AppKeys.submittingUpper)
                      : isLastQuestion
                      ? context.getText(AppKeys.submitUpper)
                      : context.getText(AppKeys.continueUpper),
                  icon: isLastQuestion
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  foreground: const Color(0xFFBEFFF9),
                  onTap: isSubmitting ? null : onContinue,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.teal700, Color(0xFF73F1E7)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
