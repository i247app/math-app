import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateHomeworkLabel extends StatelessWidget {
  const CreateHomeworkLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.andika(
        color: const Color(0xFF564148),
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
      ),
    );
  }
}
