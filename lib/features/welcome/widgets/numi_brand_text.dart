import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class NumiBrandText extends StatelessWidget {
  final double? fontSize;
  final double? height;
  final double letterSpacing;

  const NumiBrandText({
    super.key,
    this.fontSize,
    this.height,
    this.letterSpacing = 1,
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
            style: TextStyle(
              fontFamily: 'BagelFatOne',
              fontSize: fontSize ?? FontSize.displayExtraLarge,
              height: height,
              letterSpacing: letterSpacing,
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
