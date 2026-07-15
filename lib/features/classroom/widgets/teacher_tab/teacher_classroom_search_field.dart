import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherClassroomSearchField extends StatelessWidget {
  const TeacherClassroomSearchField({
    super.key,
    required this.scale,
    required this.controller,
  });

  final double scale;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 48 * scale,
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 16 * scale),
          Icon(Icons.search, color: colors.brandStrong, size: 24 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: TextField(
              controller: controller,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              style: GoogleFonts.andika(
                color: colors.textPrimary,
                fontSize: FontSize.normal * scale,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: context.getText(AppKeys.teacherSearchClassroomHint),
                hintStyle: GoogleFonts.andika(
                  color: colors.inputHint,
                  fontSize: FontSize.normal * scale,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          Icon(Icons.tune, color: colors.brandStrong, size: 24 * scale),
          SizedBox(width: 16 * scale),
        ],
      ),
    );
  }
}
