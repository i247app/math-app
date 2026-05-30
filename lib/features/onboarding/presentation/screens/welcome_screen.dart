import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  static const _brandTeal = Color(0xFF2C8B8D);
  static const _buttonCoral = Color(0xFFF97952);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final shortSide = math.min(width, height);
        final mascotSize = math.min(width * 1.12, height * 0.50);
        final logoFontSize = math.min(width * 0.111, height * 0.05);
        final buttonWidth = width * 0.64;
        final buttonHeight = height * 0.073;
        final topSpacing = height * 0.119;
        final logoSpacing = height * 0.01;
        final buttonSpacing = height * 0.10;

        return ColoredBox(
          color: Colors.white,
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
                SizedBox(height: topSpacing),
                SizedBox(
                  width: mascotSize,
                  height: mascotSize,
                  child: Image.asset(
                    'assets/images/onboarding_splash_mascot.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: logoSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.11),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'NUMINUMI',
                      maxLines: 1,
                      style: GoogleFonts.andika(
                        color: _brandTeal,
                        fontSize: logoFontSize,
                        fontWeight: FontWeight.w700,
                        height: 0.62,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: buttonSpacing),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: _StartButton(
                    onPressed: onStart,
                    height: buttonHeight,
                    fontSize: shortSide * 0.05,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.onPressed,
    required this.height,
    required this.fontSize,
  });

  final VoidCallback onPressed;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WelcomeScreen._buttonCoral,
      borderRadius: BorderRadius.circular(height * 0.34),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Text(
            context.getText(AppKeys.start),
            maxLines: 1,
            style: GoogleFonts.andika(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1.56,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
