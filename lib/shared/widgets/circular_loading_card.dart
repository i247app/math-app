import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

/// A simple loading indicator card — a [CircularProgressIndicator] centred
/// inside a rounded white card.
///
/// Can be used anywhere in the app as a lightweight inline loading state.
/// Replaces [_StudentLoadingPanel] and any similar inline spinner widgets.
class CircularLoadingCard extends StatelessWidget {
  const CircularLoadingCard({
    super.key,
    this.width = double.infinity,
    this.height = 132,
    this.scale = 1.0,
    this.borderRadius,
    this.backgroundColor,
    this.strokeWidth = 3,
  });

  final double width;
  final double height;
  final double scale;
  final double? borderRadius;
  final Color? backgroundColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = borderRadius ?? 28 * scale;
    return Container(
      width: width,
      height: height * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? colors.elevatedSurface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(
        width: 26 * scale,
        height: 26 * scale,
        child: CircularProgressIndicator(
          color: colors.brandStrong,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
