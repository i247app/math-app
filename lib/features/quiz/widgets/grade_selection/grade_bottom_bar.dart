import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
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
    final colors = context.themeColors;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 72,
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
          decoration: BoxDecoration(
            color: colors.elevatedSurface.withValues(alpha: 0.90),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 22,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            spacing: 20,
            children: [
              Expanded(
                flex: 9,
                child: PillActionButton(
                  label: context.getText(AppKeys.skipUpper),
                  background: AppColors.peachSoft,
                  foreground: AppColors.rust,
                  onPressed: onSkip,
                ),
              ),
              Expanded(
                flex: 10,
                child: PillActionButton(
                  label: context.getText(AppKeys.continueUpper),
                  icon: Icons.arrow_forward_rounded,
                  background: AppColors.teal700,
                  foreground: Colors.white,
                  gradient: const LinearGradient(
                    colors: [AppColors.teal700, Color(0xFF55E0D6)],
                  ),
                  onPressed: onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
