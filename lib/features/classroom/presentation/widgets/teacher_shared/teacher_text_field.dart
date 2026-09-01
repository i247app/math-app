import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/presentation/widgets/teacher_shared/teacher_field_shell.dart';
import 'package:numi/features/classroom/presentation/widgets/teacher_shared/teacher_shared_helpers.dart';

class TeacherTextField extends StatelessWidget {
  const TeacherTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TeacherFieldShell(
      label: label,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: const TextStyle(
          color: AppColors.textInkDark,
          fontSize: FontSize.normal,
          fontWeight: FontWeight.w400,
        ),
        decoration: teacherInputDecoration(hintText: hintText),
      ),
    );
  }
}
