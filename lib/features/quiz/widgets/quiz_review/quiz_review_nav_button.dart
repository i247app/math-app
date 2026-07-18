import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_centered_text.dart';

class QuizReviewNavButton extends StatelessWidget {
  const QuizReviewNavButton({
    super.key,
    required this.label,
    required this.icon,
    required this.filled,
    required this.enabled,
    required this.onTap,
    this.iconAfter = false,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool enabled;
  final VoidCallback onTap;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : AppColors.teal600;
    final child = Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          if (!iconAfter) Icon(icon, color: foreground, size: 20),
          QuizReviewCenteredText(
            label,
            color: foreground,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            verticalOffset: 0.4,
          ),
          if (iconAfter) Icon(icon, color: foreground, size: 20),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: filled ? AppColors.teal600 : Colors.white,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.teal600, width: 1.2),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: AppColors.teal600.withValues(alpha: 0.24),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
