import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/features/classroom/presentation/student_class_detail_style.dart';

class StudentClassTeacherAvatarInitial extends StatelessWidget {
  const StudentClassTeacherAvatarInitial({
    super.key,
    required this.initial,
  });

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDF0F5),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.andika(
          color: studentClassPink,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
