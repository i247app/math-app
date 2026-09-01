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
    this.disabledBackground,
    this.disabledForeground,
    this.labelFontSize = FontSize.xxs,
    this.borderRadius = 18,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final VoidCallback? onTap;
  final Color? background;
  final Gradient? gradient;
  final Color? disabledBackground;
  final Color? disabledForeground;
  final double labelFontSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final enabled = onTap != null;
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveForeground = enabled
        ? foreground
        : disabledForeground ?? colorScheme.onSurface.withValues(alpha: 0.38);
    final effectiveBackground = enabled
        ? background
        : disabledBackground ?? colorScheme.onSurface.withValues(alpha: 0.12);
    final effectiveGradient = enabled ? gradient : null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            color: effectiveBackground,
            gradient: effectiveGradient,
            borderRadius: BorderRadius.circular(borderRadius),
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
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
