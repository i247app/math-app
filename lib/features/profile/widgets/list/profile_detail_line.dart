import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/font_size.dart';

class ProfileDetailLine extends StatelessWidget {
  const ProfileDetailLine({
    super.key,
    required this.leading,
    required this.label,
    required this.value,
    required this.color,
    this.labelWeight = FontWeight.w700,
    this.valueWeight = FontWeight.w700,
  });

  final Widget leading;
  final String label;
  final String value;
  final Color color;
  final FontWeight labelWeight;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        leading,
        Text(
          '$label : ',
          style: GoogleFonts.andika(
            color: color,
            fontSize: FontSize.small,
            fontWeight: labelWeight,
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
              fontSize: FontSize.small,
              fontWeight: valueWeight,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
