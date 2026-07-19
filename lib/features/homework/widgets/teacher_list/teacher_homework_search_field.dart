import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class TeacherHomeworkSearchField extends StatelessWidget {
  const TeacherHomeworkSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 49,
      padding: const EdgeInsets.fromLTRB(26, 0, 18, 0),
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: colors.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/teacher_homework_search.svg',
            width: 18,
            height: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Text(
                context.getText(AppKeys.teacherAssignmentSearchHint),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: colors.inputHint,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SvgPicture.asset(
              'assets/images/teacher_homework_filter.svg',
              width: 18,
              height: 18,
            ),
          ),
        ],
      ),
    );
  }
}
