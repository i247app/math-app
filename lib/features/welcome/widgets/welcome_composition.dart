import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/welcome/widgets/numi_brand_text.dart';
import 'package:numi_flutter/features/welcome/widgets/welcome_start_button.dart';
import 'package:numi_flutter/features/welcome/widgets/welcome_style.dart';

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
        final scale = math.min(width / _designWidth, height / _designHeight);
        final contentWidth = math.min(width, _designWidth * scale);
        final compact = height < 720;

        double s(double value) => value * scale;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: ColoredBox(color: WelcomeStyle.background),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: s(375),
              child: IgnorePointer(
                child: _WelcomeBottomArt(
                  scale: scale,
                  wavesAsset: _wavesAsset,
                  booksAsset: _booksAsset,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                height: height,
                child: Column(
                  children: [
                    SizedBox(height: compact ? s(44) : s(70)),
                    SizedBox(
                      width: s(compact ? 252 : 284),
                      height: s(compact ? 252 : 284),
                      child: Image.asset(_mascotAsset, fit: BoxFit.contain),
                    ),
                    SizedBox(height: compact ? s(4) : s(2)),
                    SizedBox(
                      width: s(211),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: NumiBrandText(fontSize: s(40)),
                      ),
                    ),
                    SizedBox(height: s(8)),
                    _WelcomeTagline(scale: scale),
                    SizedBox(height: s(11)),
                    Container(
                      width: s(48),
                      height: s(6),
                      decoration: BoxDecoration(
                        color: WelcomeStyle.taglineCoral,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: s(230),
                      height: s(58),
                      child: WelcomeStartButton(
                        onStart: onStart,
                        scale: scale,
                        labelKey: AppKeys.start,
                        showArrow: false,
                      ),
                    ),
                    SizedBox(height: compact ? s(36) : s(54)),
                  ],
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
    return const Column(
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
                color: WelcomeStyle.teal,
              ),
            ),
            Text(
              'AI',
              style: TextStyle(
                fontSize: FontSize.xxl,
                fontWeight: FontWeight.w500,
                color: WelcomeStyle.taglineCoral,
              ),
            ),
          ],
        ),
        Text(
          'Học & Đánh giá',
          style: TextStyle(
            fontSize: FontSize.xxl,
            fontWeight: FontWeight.w500,
            color: WelcomeStyle.teal,
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
          top: 74 * scale,
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
