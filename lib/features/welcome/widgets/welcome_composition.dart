import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/welcome/widgets/numi_brand_text.dart';
import 'package:numi/features/welcome/widgets/welcome_login_button.dart';
import 'package:numi/features/welcome/widgets/welcome_start_button.dart';

class WelcomeComposition extends StatelessWidget {
  const WelcomeComposition({
    super.key,
    required this.onStart,
    required this.onLogin,
  });

  final VoidCallback onStart;
  final VoidCallback onLogin;

  static const _designWidth = 390.0;
  static const _designHeight = 800.0;
  static const _mascotAsset = 'assets/images/welcome_figma_mascot.png';
  static const _wavesAsset = 'assets/images/welcome_figma_waves.png';
  static const _booksAsset = 'assets/images/welcome_figma_books.png';

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final scale = math.min(width / _designWidth, height / _designHeight);
        final contentWidth = math.min(width, _designWidth * scale);
        final compact = height < 720;
        final bottomSafe = MediaQuery.paddingOf(context).bottom;

        double s(double value) => value * scale;
        final buttonBottom = math.max(
          bottomSafe + s(24),
          compact ? s(30) : s(48),
        );
        final buttonHeight = s(58);
        final loginButtonHeight = s(34);
        final buttonGap = s(12);
        final startButtonBottom = buttonBottom + loginButtonHeight + buttonGap;
        final bottomArtHeight = math.min(s(375), height * 0.5);
        final mascotSize = math.min(
          s(compact ? 236 : 284),
          math.max(s(176), height - startButtonBottom - buttonHeight - s(236)),
        );

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(child: ColoredBox(color: colors.pageBackground)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomArtHeight,
              child: IgnorePointer(
                child: _WelcomeBottomArt(
                  scale: bottomArtHeight / 375,
                  wavesAsset: _wavesAsset,
                  booksAsset: _booksAsset,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: startButtonBottom,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: s(230),
                  height: buttonHeight,
                  child: WelcomeStartButton(
                    onStart: onStart,
                    scale: scale,
                    labelKey: AppKeys.start,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: buttonBottom,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: s(230),
                  height: loginButtonHeight,
                  child: WelcomeLoginButton(
                    onLogin: onLogin,
                    scale: scale,
                    labelKey: AppKeys.welcomeLogin,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: compact ? s(14) : s(29)),
                      SizedBox(
                        width: mascotSize,
                        height: mascotSize,
                        child: Image.asset(_mascotAsset, fit: BoxFit.contain),
                      ),
                      SizedBox(height: compact ? s(4) : s(2)),
                      Transform.translate(
                        offset: Offset(0, -s(22)),
                        child: Column(
                          children: [
                            SizedBox(
                              width: s(211),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: NumiBrandText(fontSize: s(40)),
                              ),
                            ),
                            SizedBox(height: s(6)),
                            _WelcomeTagline(scale: scale),
                            SizedBox(height: s(11)),
                            Container(
                              width: s(48),
                              height: s(6),
                              decoration: BoxDecoration(
                                color: colors.accentStrong,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WelcomeTagline extends StatelessWidget {
  const _WelcomeTagline({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Toán ',
              style: TextStyle(
                fontSize: FontSize.xxl,
                fontWeight: FontWeight.w500,
                color: colors.brand,
              ),
            ),
            Text(
              'AI',
              style: TextStyle(
                fontSize: FontSize.xxl,
                fontWeight: FontWeight.w500,
                color: colors.accentStrong,
              ),
            ),
          ],
        ),
        Text(
          'Học & Đánh giá',
          style: TextStyle(
            fontSize: FontSize.xxl,
            fontWeight: FontWeight.w500,
            color: colors.brand,
          ),
        ),
      ],
    );
  }
}

class _WelcomeBottomArt extends StatelessWidget {
  const _WelcomeBottomArt({
    required this.scale,
    required this.wavesAsset,
    required this.booksAsset,
  });

  final double scale;
  final String wavesAsset;
  final String booksAsset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 0,
          width: 470 * scale,
          height: 375 * scale,
          child: Opacity(
            opacity: 0.7,
            child: Image.asset(
              wavesAsset,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          top: 24 * scale,
          width: 361 * scale,
          height: 209 * scale,
          child: Image.asset(
            booksAsset,
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
          ),
        ),
      ],
    );
  }
}
