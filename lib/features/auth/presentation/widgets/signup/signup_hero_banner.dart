import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

class SignupHeroBanner extends StatelessWidget {
  const SignupHeroBanner({
    super.key,
    required this.title,
    required this.titleFontSize,
    required this.onBack,
    required this.frameHorizontalPadding,
    required this.topGap,
  });

  final String title;
  final double titleFontSize;
  final VoidCallback onBack;
  final double frameHorizontalPadding;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return SizedBox(
      height: 122,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -64,
            right: -64,
            top: -92,
            height: 218,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/signup-cloud-background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topRight,
              ),
            ),
          ),
          Positioned(
            right: -18,
            top: 8,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/signup-rocket.png',
                width: 148,
                height: 122,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: -frameHorizontalPadding,
            right: -frameHorizontalPadding,
            top: -topGap,
            child: PageHeader(
              scale: 1,
              topInset: 0,
              backgroundColor: Colors.transparent,
              actionWidth: 44,
              horizontalPadding: 20,
              verticalPadding: 8,
              leading: AppBackButton(onPressed: onBack),
            ),
          ),
          Positioned(
            left: 0,
            top: 76,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: colors.brandStrong,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                height: 1.05,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
