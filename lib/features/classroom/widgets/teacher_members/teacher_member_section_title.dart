import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherMemberSectionTitle extends StatelessWidget {
  const TeacherMemberSectionTitle({
    super.key,
    required this.scale,
    required this.title,
  });

  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.andika(
        color: const Color(0xFF1E3A5F),
        fontSize: 18 * scale,
        fontWeight: FontWeight.w700,
        height: 1.55,
      ),
    );
  }
}
