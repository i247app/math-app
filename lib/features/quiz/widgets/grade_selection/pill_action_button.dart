import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

class PillActionButton extends StatelessWidget {
  const PillActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.scale,
    required this.onPressed,
    this.icon,
    this.gradient,
  });

  final String label;
  final Color background;
  final Color foreground;
  final double scale;
  final VoidCallback onPressed;
  final IconData? icon;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44 * scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null ? background : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: gradient == null
              ? null
              : [
                  BoxShadow(
                    color: AppColors.teal700.withValues(alpha: 0.24),
                    blurRadius: 12 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0.8,
                  ),
                ),
                if (icon != null) ...[
                  SizedBox(width: 8 * scale),
                  Icon(icon, size: 18 * scale),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
