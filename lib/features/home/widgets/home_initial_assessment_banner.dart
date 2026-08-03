import 'package:flutter/material.dart';

import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class HomeInitialAssessmentBanner extends StatelessWidget {
  const HomeInitialAssessmentBanner({super.key, required this.onTap});

  final VoidCallback onTap;

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
            aspectRatio: 1280 / 852,
            child: Ink.image(
              image: const AssetImage(homeInitialAssessmentBannerAsset),
              fit: BoxFit.cover,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
