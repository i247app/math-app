import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/features/homework/widgets/student_list/student_homework_style.dart';

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
          color: studentHomeworkMuted,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 22 / 15,
        ),
      ),
    );
  }
}
