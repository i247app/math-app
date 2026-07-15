import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherClassDetailMetaRow extends StatelessWidget {
  const TeacherClassDetailMetaRow({
    super.key,
    required this.scale,
    required this.iconAsset,
    required this.text,
  });

  final double scale;
  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20 * scale,
      child: Row(
        children: [
          Image.asset(
            iconAsset,
            width: 18 * scale,
            height: 18 * scale,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: const Color(0xFF001741),
                fontSize: 14 * scale,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
