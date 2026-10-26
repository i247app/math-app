import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class ProfileAddButton extends StatelessWidget {
  const ProfileAddButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? colors.accent : const Color(0xFFFF8A3D),
      elevation: 4,
      shadowColor: const Color(0xFFFF8A3D).withValues(alpha: 0.20),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 34,
          child: Icon(
            Icons.add_rounded,
            color: isDark ? colors.onAccent : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
