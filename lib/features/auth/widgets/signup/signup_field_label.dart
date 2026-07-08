import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/app_theme_colors.dart';

class SignupFieldLabel extends StatelessWidget {
  const SignupFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return RichText(
      text: TextSpan(
        style: GoogleFonts.andika(
          color: colors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(color: colors.error),
            ),
        ],
      ),
    );
  }
}
