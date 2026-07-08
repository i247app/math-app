import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/app_theme_colors.dart';

class PasscodeSkipButton extends StatelessWidget {
  const PasscodeSkipButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColor = onPressed == null
        ? colors.textPrimary.withValues(alpha: 0.45)
        : colors.textPrimary;

    return Center(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: GoogleFonts.andika(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 20 / 16,
              decoration: TextDecoration.underline,
              decorationColor: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
