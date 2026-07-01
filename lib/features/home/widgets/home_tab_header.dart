import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/font_size.dart';

class HomeTabHeader extends StatelessWidget {
  const HomeTabHeader({
    super.key,
    required this.title,
    required this.scale,
    this.topInset,
  });

  final String title;
  final double scale;
  final double? topInset;

  @override
  Widget build(BuildContext context) {
    final resolvedTopInset = topInset ?? MediaQuery.paddingOf(context).top;
    return Container(
      height: resolvedTopInset + 60 * scale,
      padding: EdgeInsets.only(top: resolvedTopInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFF2F2F2), width: 4 * scale),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: const Color(0xFF339395),
          fontSize: FontSize.xxxl,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
