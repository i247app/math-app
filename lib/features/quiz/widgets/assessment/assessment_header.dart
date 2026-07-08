import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/features/quiz/widgets/shared/quiz_header_icon_button.dart';

class AssessmentHeader extends StatelessWidget {
  const AssessmentHeader({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32 * scale)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 80 * scale,
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          decoration: BoxDecoration(
            color: AppColors.gradeBackground.withValues(alpha: 0.84),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(32 * scale),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF253228).withValues(alpha: 0.05),
                blurRadius: 2 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              QuizHeaderIconButton(
                icon: Icons.close_rounded,
                color: AppColors.teal700,
                scale: scale,
                circle: true,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Text(
                  context.getText(AppKeys.aiChallenge),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.teal700,
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              QuizHeaderIconButton(
                icon: Icons.help_outline_rounded,
                color: AppColors.teal700,
                scale: scale,
                circle: true,
                onTap: HapticFeedback.selectionClick,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
