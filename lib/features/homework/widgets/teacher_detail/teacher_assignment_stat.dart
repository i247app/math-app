import 'package:numi/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherAssignmentStat extends StatelessWidget {
  const TeacherAssignmentStat({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.value,
    required this.valueFontSize,
  });

  final String label;
  final String iconAsset;
  final String value;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: const Color(0xFF444650),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            letterSpacing: 0.6,
          ),
        ),
        Row(
          spacing: 8,
          children: [
            SvgPicture.asset(iconAsset, width: 15, height: 15),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: AppColors.textInkDark,
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w400,
                  height: 24 / valueFontSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
