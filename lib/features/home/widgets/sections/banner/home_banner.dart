import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_shadows.dart';
import 'package:numi/features/home/widgets/sections/banner/home_banner_data.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key, required this.data, this.useCardShadow = false});

  static const double aspectRatio = 1280 / 852;

  final HomeBannerData data;
  final bool useCardShadow;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final borderRadius = BorderRadius.circular(30);

    return Semantics(
      button: true,
      label: data.semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: useCardShadow
              ? AppShadows.card(colors)
              : [
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
            onTap: data.onTap,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Ink.image(
                image: data.image,
                fit: data.fit,
                alignment: data.alignment,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
