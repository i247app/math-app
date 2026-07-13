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
    // Exact hex color codes from welcome.jpg
    final Color tealBrandColor = firstColor ?? const Color(0xFF1C8E9B);
    final Color orangeBrandColor = secondColor ?? const Color(0xFFF16634);

    final double baseSize = fontSize ?? 42.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Brand Title using Bagel Fat One
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.bagelFatOne(
              fontSize: baseSize,
              letterSpacing: 1.0,
            ),
            children: [
              TextSpan(text: 'NUMI', style: TextStyle(color: tealBrandColor)),
              TextSpan(text: 'NUMI', style: TextStyle(color: orangeBrandColor)),
            ],
          ),
        ),
        const SizedBox(height: 2),

        // 2. Subtitle Main using Bagel Fat One
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.bagelFatOne(
              fontSize: baseSize * 0.55,
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(text: 'Math ', style: TextStyle(color: tealBrandColor)),
              TextSpan(text: 'AI', style: TextStyle(color: orangeBrandColor)),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // 3. Description Subtitle
        Text(
          'Learning & Assessment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: baseSize * 0.48,
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