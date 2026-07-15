import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_field_shell.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_shared_helpers.dart';

class TeacherTextField extends StatelessWidget {
  const TeacherTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.scale,
    this.maxLines = 1,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final double scale;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TeacherFieldShell(
      label: label,
      scale: scale,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: GoogleFonts.andika(
          color: AppColors.textInkDark,
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w400,
        ),
        decoration: teacherInputDecoration(hintText: hintText, scale: scale),
      ),
    );
  }
}
