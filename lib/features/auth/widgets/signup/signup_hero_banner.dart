import 'package:flutter/material.dart';

import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

class SignupHeroBanner extends StatelessWidget {
  const SignupHeroBanner({
    super.key,
    required this.onBack,
    required this.frameHorizontalPadding,
    required this.topGap,
  });

  final VoidCallback onBack;
  final double frameHorizontalPadding;
  final double topGap;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
