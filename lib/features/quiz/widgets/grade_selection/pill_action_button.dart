import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class PillActionButton extends StatelessWidget {
  const PillActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
    this.gradient,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
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
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            shape: const StadiumBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: FontSize.xxs,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
