import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/font_size.dart';

class AddProfileFieldShell extends StatelessWidget {
  const AddProfileFieldShell({
    super.key,
    required this.label,
    required this.child,
    required this.scale,
  });

  final String label;
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: const Color(0xFF604950),
            fontSize: FontSize.small * scale,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(
          height: 56 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: const Color(0xFFD8E4E7), width: 1.6),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }
}
