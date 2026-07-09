import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    super.key,
    required this.onPressed,
    this.iconAsset = 'assets/images/pin_figma_back.svg',
    this.size = 44,
  });

  final VoidCallback onPressed;
  final String iconAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return SizedBox.square(
      dimension: size,
      child: Material(
        color: colors.authBackSurface,
        shadowColor: colors.shadow,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: colors.authBackBorder),
        ),
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onPressed();
          },
          borderRadius: BorderRadius.circular(999),
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                colors.brandStrong,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
