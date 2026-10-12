import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_centered_text.dart';

class ExamReviewNavButton extends StatelessWidget {
  const ExamReviewNavButton({
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
    final colors = context.themeColors;
    final foreground = filled ? colors.onPrimaryAction : colors.primaryAction;
    final child = Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          if (!iconAfter) Icon(icon, color: foreground, size: 20),
          Flexible(
            child: ExamReviewCenteredText(
              label,
              color: foreground,
              fontSize: FontSize.compact,
              fontWeight: FontWeight.w900,
              verticalOffset: 0.4,
            ),
          ),
          if (iconAfter) Icon(icon, color: foreground, size: 20),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: filled ? colors.primaryAction : colors.elevatedSurface,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: colors.primaryAction, width: 1.2),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: colors.primaryAction.withValues(alpha: 0.24),
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
