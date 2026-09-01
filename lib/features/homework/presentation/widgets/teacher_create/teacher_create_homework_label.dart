import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
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
        fontSize: FontSize.small,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
      ),
    );
  }
}
