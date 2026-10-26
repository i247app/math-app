import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class NumiBrandText extends StatelessWidget {
  final double? fontSize;
  final double? height;
  final double letterSpacing;
  final Color firstColor;
  final Color secondColor;

  const NumiBrandText({
    super.key,
    this.fontSize,
    this.height,
    this.letterSpacing = 1,
    this.firstColor = AppColors.brandLogoTeal,
    this.secondColor = AppColors.brandLogoOrange,
  });

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
              fontSize: fontSize ?? FontSize.displayExtraLarge,
              height: height,
              letterSpacing: letterSpacing,
            ),
            children: [
              TextSpan(
                text: 'NUMI',
                style: TextStyle(color: firstColor),
              ),
              TextSpan(
                text: 'NUMI',
                style: TextStyle(color: secondColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
