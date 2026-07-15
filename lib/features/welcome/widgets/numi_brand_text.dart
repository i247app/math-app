import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/app_colors.dart';

class NumiBrandText extends StatelessWidget {
  final double? fontSize;

  const NumiBrandText({super.key, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Brand Title - "NUMINUMI"
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.bagelFatOne(
              fontSize: fontSize ?? 42.0, // Fixed size for the main title
              letterSpacing: 1.0,
            ),
            children: [
              const TextSpan(
                text: 'NUMI',
                style: TextStyle(color: AppColors.brandTeal),
              ),
              const TextSpan(
                text: 'NUMI',
                style: TextStyle(color: AppColors.brandOrange),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
