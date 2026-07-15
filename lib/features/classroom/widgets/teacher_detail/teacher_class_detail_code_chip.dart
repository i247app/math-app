import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class TeacherClassDetailCodeChip extends StatelessWidget {
  const TeacherClassDetailCodeChip({
    super.key,
    required this.scale,
    required this.code,
    required this.onCopy,
  });

  final double scale;
  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 27 * scale,
      constraints: BoxConstraints(minWidth: 114 * scale, maxWidth: 190 * scale),
      padding: EdgeInsets.symmetric(horizontal: 17 * scale),
      decoration: BoxDecoration(
        color: colors.brand.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                code,
                maxLines: 1,
                style: GoogleFonts.andika(
                  color: colors.textPrimary,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.8,
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8 * scale),
            child: Padding(
              padding: EdgeInsets.all(2 * scale),
              child: SvgPicture.asset(
                'assets/images/teacher_class_link_copy.svg',
                width: 20 * scale,
                height: 20 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
