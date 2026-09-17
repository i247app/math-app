import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherPrimaryButton extends StatelessWidget {
  const TeacherPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final double width;
  final double height;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: onPressed == null
                ? null
                : [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: onPressed == null
                ? colors.disabledBackground
                : colors.brandStrong,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: context.textStyles.titleLarge?.copyWith(
                      color: colors.onBrand,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  Icon(icon, color: colors.onBrand, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
