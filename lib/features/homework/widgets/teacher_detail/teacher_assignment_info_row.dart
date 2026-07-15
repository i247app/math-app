import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_labeled_value.dart';

class TeacherAssignmentInfoRow extends StatelessWidget {
  const TeacherAssignmentInfoRow(this.row, {super.key});

  final TeacherAssignmentLabeledValue row;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: GoogleFonts.andika(
          color: const Color(0xFF444650),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 24 / 14,
        ),
        children: [
          TextSpan(
            text: '${row.label}: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: row.value),
        ],
      ),
    );
  }
}
