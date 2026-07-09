import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

class StudentHomeworkAttemptBottomActionButton extends StatelessWidget {
  const StudentHomeworkAttemptBottomActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.foreground,
    required this.scale,
    required this.onTap,
    this.background,
    this.gradient,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final double scale;
  final VoidCallback? onTap;
  final Color? background;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final effectiveForeground = enabled
        ? foreground
        : foreground.withValues(alpha: 0.38);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 48 * scale,
          decoration: BoxDecoration(
            color: background?.withValues(alpha: enabled ? 1 : 0.42),
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: gradient == null
                ? null
                : [
                    BoxShadow(
                      color: AppColors.teal700.withValues(alpha: 0.20),
                      blurRadius: 6 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: effectiveForeground, size: 16 * scale),
              SizedBox(width: 8 * scale),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: effectiveForeground,
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w900,
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
