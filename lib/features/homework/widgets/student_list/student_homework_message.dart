import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/app_colors.dart';

class StudentHomeworkMessage extends StatelessWidget {
  const StudentHomeworkMessage({super.key, required this.message});

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
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 22 / 15,
        ),
      ),
    );
  }
}
