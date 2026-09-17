import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onPressed,
    this.iconAsset = 'assets/icons/pin-figma-back.svg',
    this.size = 44,
    this.iconSize = 16,
    this.color,
  });

  final VoidCallback onPressed;
  final String iconAsset;
  final double size;
  final double iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return SizedBox.square(
      dimension: size,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onPressed();
          },
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(
                color ?? colors.brandStrong,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
