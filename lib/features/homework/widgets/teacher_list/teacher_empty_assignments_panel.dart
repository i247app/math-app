import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class TeacherEmptyAssignmentsPanel extends StatelessWidget {
  const TeacherEmptyAssignmentsPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: colors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
