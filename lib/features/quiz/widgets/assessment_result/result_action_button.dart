import 'package:flutter/material.dart';

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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 57,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
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
            spacing: 8,
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
