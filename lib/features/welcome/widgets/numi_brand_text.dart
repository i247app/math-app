import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/app_theme_colors.dart';

class NumiBrandText extends StatelessWidget {
  const NumiBrandText({
    super.key,
    required this.fontSize,
    this.firstColor,
    this.secondColor,
  });

  final double fontSize;
  final Color? firstColor;
  final Color? secondColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final resolvedFirstColor = firstColor ?? colors.brand;
    final resolvedSecondColor = secondColor ?? colors.accent;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'NUMI',
            style: GoogleFonts.bagelFatOne(
              color: resolvedFirstColor,
              fontSize: fontSize,
              height: 1,
            ),
          ),
          TextSpan(
            text: 'NUMI',
            style: GoogleFonts.bagelFatOne(
              color: resolvedSecondColor,
              fontSize: fontSize,
              height: 1,
            ),
          ),
        ],
      ),
      maxLines: 1,
      softWrap: false,
    );
  }
}
