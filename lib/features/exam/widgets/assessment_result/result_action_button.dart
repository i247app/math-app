import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_radius.dart';
import 'package:numi/core/theme/app_spacing.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

class AssessmentResultActionButton extends StatelessWidget {
  const AssessmentResultActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color background;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(AppRadius.r20);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          height: 57,
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpacing.s8,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: context.textStyles.titleLarge?.copyWith(
                      color: colors.onBrand,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w800,
                      height: 28 / 18,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, color: colors.onBrand, size: 18, weight: 700),
            ],
          ),
        ),
      ),
    );
  }
}
