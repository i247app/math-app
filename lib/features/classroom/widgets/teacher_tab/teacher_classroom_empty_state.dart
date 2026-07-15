import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherClassroomEmptyState extends StatelessWidget {
  const TeacherClassroomEmptyState({
    super.key,
    required this.scale,
    required this.message,
  });

  final double scale;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.andika(
            color: AppColors.textCoolMuted,
            fontSize: FontSize.normal * scale,
          ),
        ),
      ),
    );
  }
}
