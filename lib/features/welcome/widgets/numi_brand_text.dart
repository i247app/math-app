import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/app_colors.dart';

class NumiBrandText extends StatelessWidget {
  const NumiBrandText({
    super.key,
    required this.fontSize,
    this.firstColor = AppColors.welcomeTeal,
    this.secondColor = AppColors.coral600,
  });

  final double fontSize;
  final Color firstColor;
  final Color secondColor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'NUMI',
            style: GoogleFonts.bagelFatOne(
              color: firstColor,
              fontSize: fontSize,
              height: 1,
            ),
          ),
          TextSpan(
            text: 'NUMI',
            style: GoogleFonts.bagelFatOne(
              color: secondColor,
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
