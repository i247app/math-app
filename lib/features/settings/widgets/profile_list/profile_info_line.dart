import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/font_size.dart';

class ProfileInfoLine extends StatelessWidget {
  const ProfileInfoLine({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.scale,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18 * scale),
        SizedBox(width: 8 * scale),
        Text(
          '$label : ',
          style: GoogleFonts.andika(
            color: iconColor,
            fontSize: FontSize.small * scale,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: iconColor,
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
