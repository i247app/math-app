import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/app_theme_colors.dart';
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
    final colors = context.themeColors;
    final resolvedTopInset = topInset ?? MediaQuery.paddingOf(context).top;
    return Container(
      height: resolvedTopInset + 60 * scale,
      padding: EdgeInsets.only(top: resolvedTopInset),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        border: Border(
          bottom: BorderSide(color: colors.border, width: 4 * scale),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: colors.brandStrong,
          fontSize: FontSize.xxxl,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
