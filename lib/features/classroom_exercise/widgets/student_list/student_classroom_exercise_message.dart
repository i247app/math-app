import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_colors.dart';

class StudentClassroomExerciseMessage extends StatelessWidget {
  const StudentClassroomExerciseMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: AppColors.textMuted,
          fontSize: FontSize.compact,
          fontWeight: FontWeight.w500,
          height: 22 / 15,
        ),
      ),
    );
  }
}
