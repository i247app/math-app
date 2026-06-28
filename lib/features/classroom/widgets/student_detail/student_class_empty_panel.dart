import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/features/classroom/presentation/student_class_detail_style.dart';

class StudentClassEmptyPanel extends StatelessWidget {
  const StudentClassEmptyPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: studentClassMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
        ),
      ),
    );
  }
}
