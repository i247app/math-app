import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final Color tealBrandColor = firstColor ?? const Color(0xFF1C8E9B);
    final Color orangeBrandColor = secondColor ?? const Color(0xFFF16634);

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
              TextSpan(text: 'NUMI', style: TextStyle(color: tealBrandColor)),
              TextSpan(text: 'NUMI', style: TextStyle(color: orangeBrandColor)),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // 2. Main Subtitle - "Math AI"
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.bagelFatOne(
              fontSize: 24.0, // Clean, explicit fixed sizing
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(text: 'Math ', style: TextStyle(color: tealBrandColor)),
              TextSpan(text: 'AI', style: TextStyle(color: orangeBrandColor)),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // 3. Description Subtitle - "Learning & Assessment"
        Text(
          'Learning & Assessment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0, // Clean, explicit fixed sizing
            fontWeight: FontWeight.w500,
            color: tealBrandColor,
          ),
        ),
        const SizedBox(height: 14),

        // 4. Capsule Indicator bar
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: orangeBrandColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}