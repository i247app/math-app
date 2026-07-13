import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/app_colors.dart';

class NumiBrandText extends StatelessWidget {
  final double? fontSize;
  final Color? firstColor;
  final Color? secondColor;

  const NumiBrandText({
    super.key,
    this.fontSize,
    this.firstColor,
    this.secondColor,
  });

  @override
  Widget build(BuildContext context) {
    // Exact hex color codes mapped from your design layout
    // final Color tealBrandColor = firstColor ?? const Color(0xFF1C8E9B);
    // final Color orangeBrandColor = secondColor ?? const Color(0xFFF16634);
    final Color tealBrandColor = firstColor ?? const Color(0xFF058A95);
    final Color orangeBrandColor = secondColor ?? const Color(0xFFFC6128);

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
              const TextSpan(text: 'NUMI', style: TextStyle(color: AppColors.brandTeal)),
              const TextSpan(text: 'NUMI', style: TextStyle(color: AppColors.brandOrange)),
            ],
          ),
        ),
      ],
    );
  }
}