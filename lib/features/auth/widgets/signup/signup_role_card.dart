import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class SignupRoleCard extends StatelessWidget {
  const SignupRoleCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = colors.brandStrong;
    final backgroundColor = isDark
        ? (isSelected
              ? Color.alphaBlend(
                  accentColor.withValues(alpha: 0.12),
                  colors.inputSurface,
                )
              : colors.inputSurface)
        : Colors.white;

    return SizedBox(
      height: 96,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? accentColor
                    : (isDark ? colors.borderStrong : colors.border),
                width: isSelected ? 1.6 : 1.2,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(imagePath, height: 48, fit: BoxFit.contain),
                      const SizedBox(height: 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: isSelected
                                    ? accentColor
                                    : colors.textPrimary,
                                fontSize: FontSize.small,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -19,
                    right: -14,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? colors.elevatedSurface : Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: isDark ? colors.onPrimaryAction : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
