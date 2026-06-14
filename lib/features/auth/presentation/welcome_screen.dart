import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';

class WelcomeScreen extends StatefulWidget {
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
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _didPrecacheNextScreenAssets = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheNextScreenAssets) {
      return;
    }

    _didPrecacheNextScreenAssets = true;
    precacheImage(
      const AssetImage('assets/images/numi-mascot.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: WelcomeScreen._background,
        child: SafeArea(
          bottom: false,
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
                        child: _WelcomeComposition(onStart: widget.onStart),
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
              child: ColoredBox(color: WelcomeScreen._background),
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
                        child: Image.asset(
                          _mascotAsset,
                          fit: BoxFit.cover,
                        ),
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
                                    color: WelcomeScreen._teal,
                                    fontSize: s(40),
                                    height: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'NUMI',
                                  style: GoogleFonts.bagelFatOne(
                                    color: WelcomeScreen._coral,
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
                              color: WelcomeScreen._teal,
                              fontSize: s(18),
                              fontWeight: FontWeight.w400,
                              height: 22.5 / 18,
                            ),
                            children: [
                              const TextSpan(text: 'Học tập '),
                              TextSpan(
                                text: 'thông minh\n',
                                style: GoogleFonts.andika(
                                  color: WelcomeScreen._taglineCoral,
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
                            color: WelcomeScreen._taglineCoral,
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
                        child: _StartButton(
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

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.onStart,
    required this.scale,
  });

  final VoidCallback onStart;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20 * scale);

    return Material(
      color: WelcomeScreen._coral,
      borderRadius: radius,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onStart();
        },
        borderRadius: radius,
        child: Center(
          child: Text(
            context.getText(AppKeys.start).toUpperCase(),
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
