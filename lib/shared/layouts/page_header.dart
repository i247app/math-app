import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

/// The standard top-of-page header used by the app's scrollable screens.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.scale,
    this.title,
    this.topInset,
    this.backgroundColor,
    this.leading,
    this.trailing,
    this.actionWidth = 0,
    this.horizontalPadding = 0,
    this.verticalPadding = 0,
    this.titleFontSize = FontSize.xxxl,
    this.boxShadow,
  });

  final String? title;
  final double scale;
  final double? topInset;
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? trailing;
  final double actionWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double titleFontSize;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final resolvedTopInset = topInset ?? MediaQuery.paddingOf(context).top;
    final scaledActionWidth = actionWidth * scale;

    return Container(
      height: resolvedTopInset + 60 * scale,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.elevatedSurface,
        boxShadow: boxShadow,
      ),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding * scale,
        resolvedTopInset + verticalPadding * scale,
        horizontalPadding * scale,
        verticalPadding * scale,
      ),
      child: Row(
        children: [
          SizedBox(width: scaledActionWidth, child: leading),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Text(
                    title!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: colors.brandStrong,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
          ),
          SizedBox(width: scaledActionWidth, child: trailing),
        ],
      ),
    );
  }
}
