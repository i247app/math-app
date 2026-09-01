import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/presentation/widgets/assessment/assessment_bottom_action_button.dart';

class AssessmentErrorState extends StatelessWidget {
  const AssessmentErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.peachStrong.withValues(alpha: 0.58),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.rust,
                size: 34,
              ),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSubtle,
                fontSize: FontSize.compact,
                fontWeight: FontWeight.w800,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                width: 168,
                child: AssessmentBottomActionButton(
                  label: context.getText(AppKeys.retryUpper),
                  icon: Icons.refresh_rounded,
                  foreground: const Color(0xFFBEFFF9),
                  onTap: onRetry,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.teal700, Color(0xFF73F1E7)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
