import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class HomeAssessmentBanner extends StatelessWidget {
  const HomeAssessmentBanner({
    super.key,
    required this.asset,
    required this.onTap,
    this.alignment = Alignment.center,
  });

  static const double aspectRatio = 1280 / 852;

  final String asset;
  final VoidCallback onTap;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final borderRadius = BorderRadius.circular(30);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Ink.image(
              image: AssetImage(asset),
              fit: BoxFit.cover,
              alignment: alignment,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
