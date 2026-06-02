import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

  static const _teal = Color(0xFF2C8B8D);
  static const _coral = Color(0xFFF97952);
  static const _taglineCoral = Color(0xFFFF7043);
  static const _background = Color(0xFFFAFCFC);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: _background,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: _WelcomeComposition(onStart: onStart),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WelcomeComposition extends StatelessWidget {
  const _WelcomeComposition({required this.onStart});

  final VoidCallback onStart;

  static const _mascotAsset = 'assets/images/welcome_figma_mascot.png';
  static const _wavesAsset = 'assets/images/welcome_figma_waves.png';
  static const _booksAsset = 'assets/images/welcome_figma_books.png';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: ColoredBox(color: WelcomeScreen._background),
            ),
            Positioned(
              left: math.max(0, (constraints.maxWidth - 284) / 2),
              top: 75,
              width: 284,
              height: 284,
              child: const Image(
                image: AssetImage(_mascotAsset),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: math.max(0, (constraints.maxWidth - 211) / 2),
              top: 329,
              width: 211,
              height: 48,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'NUMI',
                        style: GoogleFonts.bagelFatOne(
                          color: WelcomeScreen._teal,
                          fontSize: 40,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'NUMI',
                        style: GoogleFonts.bagelFatOne(
                          color: WelcomeScreen._coral,
                          fontSize: 40,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
            Positioned(
              left: math.max(0, (constraints.maxWidth - 170) / 2),
              top: 385,
              width: 170,
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.andika(
                    color: WelcomeScreen._teal,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 22.5 / 18,
                  ),
                  children: [
                    const TextSpan(text: 'Học tập '),
                    TextSpan(
                      text: 'thông minh\n',
                      style: GoogleFonts.andika(
                        color: WelcomeScreen._taglineCoral,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 22.5 / 18,
                      ),
                    ),
                    const TextSpan(text: 'Tiến bộ mỗi ngày'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              left: math.max(0, (constraints.maxWidth - 48) / 2),
              top: 443,
              width: 48,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: WelcomeScreen._taglineCoral,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Positioned(
              left: (constraints.maxWidth - 470) / 2,
              top: 425,
              width: 470,
              height: 375,
              child: Opacity(
                opacity: 0.7,
                child: ClipRect(
                  child: Image.asset(
                    _wavesAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: (constraints.maxWidth - 361) / 2,
              top: 499,
              width: 361,
              height: 209,
              child: ClipRect(
                child: Image.asset(
                  _booksAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              left: math.max(0, (constraints.maxWidth - 230) / 2),
              top: 688,
              width: 230,
              height: 58,
              child: _StartButton(onStart: onStart),
            ),
          ],
        );
      },
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WelcomeScreen._coral,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onStart();
        },
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Text(
            context.getText(AppKeys.start).toUpperCase(),
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
