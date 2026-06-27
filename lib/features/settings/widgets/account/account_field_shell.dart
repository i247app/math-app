import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/font_size.dart';

class AccountFieldShell extends StatelessWidget {
  const AccountFieldShell({
    super.key,
    required this.label,
    required this.child,
    required this.scale,
    this.trailing,
  });

  final String label;
  final Widget child;
  final double scale;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: const Color(0xFF604950),
                  fontSize: FontSize.normal * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        SizedBox(height: 12 * scale),
        Container(
          height: 60 * scale,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: const Color(0xFFCFCFCF),
              width: 1.2 * scale,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }
}
