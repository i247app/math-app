import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_shadows.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class HomeImageAction extends StatelessWidget {
  const HomeImageAction({
    super.key,
    required this.asset,
    required this.height,
    required this.onTap,
    this.alignment = Alignment.center,
    this.useCardShadow = false,
  });

  final String asset;
  final double height;
  final VoidCallback onTap;
  final Alignment alignment;
  final bool useCardShadow;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: useCardShadow ? AppShadows.card(context.themeColors) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: Ink.image(
              image: AssetImage(asset),
              fit: BoxFit.cover,
              alignment: alignment,
            ),
          ),
        ),
      ),
    );
  }
}
