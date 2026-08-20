import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

class AssessmentBottomActionButton extends StatelessWidget {
  const AssessmentBottomActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.foreground,
    required this.onTap,
    this.background,
    this.gradient,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final VoidCallback? onTap;
  final Color? background;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final enabled = onTap != null;
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveForeground = enabled
        ? foreground
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final effectiveBackground = enabled
        ? background
        : colorScheme.onSurface.withValues(alpha: 0.12);
    final effectiveGradient = enabled ? gradient : null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            color: effectiveBackground,
            gradient: effectiveGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: !enabled || gradient == null
                ? null
                : [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Icon(icon, color: effectiveForeground, size: 16),
              Text(
                label,
                maxLines: 1,
                style: context.textStyles.labelSmall?.copyWith(
                  color: effectiveForeground,
                  fontSize: FontSize.xxs,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
