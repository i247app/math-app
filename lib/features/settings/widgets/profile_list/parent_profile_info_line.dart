import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/font_size.dart';

class ParentProfileInfoLine extends StatelessWidget {
  const ParentProfileInfoLine({
    super.key,
    required this.assetPath,
    required this.label,
    required this.value,
    required this.isActive,
    required this.scale,
  });

  final String assetPath;
  final String label;
  final String value;
  final bool isActive;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF008080) : const Color(0xFF6B7280);

    return Row(
      children: [
        SizedBox(
          width: 18 * scale,
          height: 18 * scale,
          child: SvgPicture.asset(assetPath),
        ),
        SizedBox(width: 8 * scale),
        Text(
          '$label : ',
          style: GoogleFonts.andika(
            color: color,
            fontSize: FontSize.small * scale,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: color,
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
