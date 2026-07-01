import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/features/auth/widgets/welcome/welcome_start_button.dart';
import 'package:numi_flutter/features/auth/widgets/welcome/welcome_style.dart';

class WelcomeComposition extends StatelessWidget {
  const WelcomeComposition({super.key, required this.onStart});

  final VoidCallback onStart;

  static const _designWidth = 390.0;
  static const _designHeight = 800.0;
  static const _mascotAsset = 'assets/images/welcome_figma_mascot.png';
  static const _wavesAsset = 'assets/images/welcome_figma_waves.png';
  static const _booksAsset = 'assets/images/welcome_figma_books.png';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final scale = math.max(width / _designWidth, height / _designHeight);
        final canvasWidth = _designWidth * scale;
        final canvasHeight = _designHeight * scale;
        final leftOffset = (width - canvasWidth) / 2;
        const topOffset = 0.0;

        double s(double value) => value * scale;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: ColoredBox(color: WelcomeStyle.background),
            ),
            Positioned(
              left: leftOffset,
              top: topOffset,
              width: canvasWidth,
              height: canvasHeight,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: s(75),
                    height: s(284),
                    child: Center(
                      child: SizedBox(
                        width: s(284),
                        height: s(284),
                        child: Image.asset(_mascotAsset, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: s(329),
                    height: s(48),
                    child: Center(
                      child: SizedBox(
                        width: s(211),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'NUMI',
                                  style: GoogleFonts.bagelFatOne(
                                    color: WelcomeStyle.teal,
                                    fontSize: s(40),
                                    height: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'NUMI',
                                  style: GoogleFonts.bagelFatOne(
                                    color: WelcomeStyle.coral,
                                    fontSize: s(40),
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
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: s(385),
                    child: Center(
                      child: SizedBox(
                        width: s(170),
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.andika(
                              color: WelcomeStyle.teal,
                              fontSize: s(18),
                              fontWeight: FontWeight.w400,
                              height: 22.5 / 18,
                            ),
                            children: [
                              const TextSpan(text: 'Học tập '),
                              TextSpan(
                                text: 'thông minh\n',
                                style: GoogleFonts.andika(
                                  color: WelcomeStyle.taglineCoral,
                                  fontSize: s(18),
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
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: s(443),
                    height: s(6),
                    child: Center(
                      child: SizedBox(
                        width: s(48),
                        height: s(6),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: WelcomeStyle.taglineCoral,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: s(425),
                    height: s(375),
                    child: Center(
                      child: SizedBox(
                        width: s(470),
                        height: s(375),
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
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: s(499),
                    height: s(209),
                    child: Center(
                      child: SizedBox(
                        width: s(361),
                        height: s(209),
                        child: ClipRect(
                          child: Image.asset(
                            _booksAsset,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: s(688),
                    height: s(58),
                    child: Center(
                      child: SizedBox(
                        width: s(230),
                        height: s(58),
                        child: WelcomeStartButton(
                          onStart: onStart,
                          scale: scale,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
