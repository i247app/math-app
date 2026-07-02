import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/features/auth/widgets/welcome/numi_brand_text.dart';
import 'package:numi_flutter/features/auth/widgets/welcome/welcome_start_button.dart';
import 'package:numi_flutter/features/auth/widgets/welcome/welcome_style.dart';

class WelcomeDetailsComposition extends StatelessWidget {
  const WelcomeDetailsComposition({
    super.key,
    required this.onStart,
    required this.onBack,
  });

  final VoidCallback onStart;
  final VoidCallback onBack;

  static const _designWidth = 360.0;
  static const _designHeight = 800.0;
  static const _assetPrefix = 'assets/images/welcome_screen/';
  static const _heroAsset = '${_assetPrefix}welcome_hero_math_friends.png';
  static const _mascotLogoAsset = '${_assetPrefix}welcome_logo_mascot.png';
  static const _assessmentAsset = '${_assetPrefix}welcome_card_assessment.png';
  static const _teacherAsset =
      '${_assetPrefix}welcome_card_teacher_support.png';
  static const _progressAsset =
      '${_assetPrefix}welcome_card_progress_tracking.png';
  static const _gameAsset = '${_assetPrefix}welcome_card_game_learning.png';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final scale = math.min(width / _designWidth, height / _designHeight);
        final canvasWidth = _designWidth * scale;
        final canvasHeight = _designHeight * scale;
        final leftOffset = (width - canvasWidth) / 2;
        final topOffset = (height - canvasHeight) / 2;

        double s(double value) => value * scale;

        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        WelcomeStyle.backgroundTop,
                        WelcomeStyle.background,
                        Colors.white,
                      ],
                      stops: [0, 0.42, 1],
                    ),
                  ),
                ),
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
                      left: s(16),
                      top: s(18),
                      width: s(156),
                      height: s(32),
                      child: _BrandLogo(onTap: onBack),
                    ),
                    Positioned(
                      left: s(-128),
                      top: s(78),
                      width: s(540),
                      height: s(360),
                      child: Image.asset(_heroAsset, fit: BoxFit.contain),
                    ),
                    Positioned(
                      left: s(16),
                      top: s(388),
                      width: s(156),
                      height: s(132),
                      child: const _FeatureCard(
                        imageAsset: _assessmentAsset,
                        imageSize: 54,
                        title: 'Đánh giá năng lực',
                        subtitle: 'Hiểu đúng trình độ của con',
                      ),
                    ),
                    Positioned(
                      left: s(184),
                      top: s(388),
                      width: s(156),
                      height: s(132),
                      child: const _FeatureCard(
                        imageAsset: _teacherAsset,
                        imageSize: 54,
                        title: 'Hỗ trợ giáo viên',
                        subtitle: 'Quản lý lớp học dễ dàng',
                      ),
                    ),
                    Positioned(
                      left: s(16),
                      top: s(532),
                      width: s(156),
                      height: s(132),
                      child: const _FeatureCard(
                        imageAsset: _progressAsset,
                        imageSize: 54,
                        title: 'Theo dõi tiến độ',
                        subtitle: 'Bám sát sự tiến bộ của con',
                      ),
                    ),
                    Positioned(
                      left: s(184),
                      top: s(532),
                      width: s(156),
                      height: s(132),
                      child: const _FeatureCard(
                        imageAsset: _gameAsset,
                        imageSize: 54,
                        title: 'Học qua game',
                        subtitle: 'Học mà chơi - Chơi mà giỏi',
                      ),
                    ),
                    Positioned(
                      left: s(24),
                      top: s(720),
                      width: s(56),
                      height: s(8),
                      child: const _PageIndicator(),
                    ),
                    Positioned(
                      left: s(202),
                      top: s(703),
                      width: s(143),
                      height: s(42),
                      child: WelcomeStartButton(onStart: onStart, scale: scale),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxHeight / 32;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(10 * scale),
            child: Row(
              children: [
                Image.asset(
                  WelcomeDetailsComposition._mascotLogoAsset,
                  width: 31 * scale,
                  height: 31 * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8 * scale),
                NumiBrandText(
                  fontSize: 20 * scale,
                  firstColor: WelcomeStyle.deepTeal,
                  secondColor: WelcomeStyle.taglineCoral,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.imageAsset,
    required this.imageSize,
    required this.title,
    required this.subtitle,
  });

  final String imageAsset;
  final double imageSize;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / 156;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF101828).withValues(alpha: 0.08),
                offset: Offset(0, 8 * scale),
                blurRadius: 20 * scale,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              12 * scale,
              18 * scale,
              12 * scale,
              12 * scale,
            ),
            child: Column(
              children: [
                Image.asset(
                  imageAsset,
                  width: imageSize * scale,
                  height: imageSize * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 12 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.nunito(
                      color: WelcomeStyle.cardTitle,
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 5 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    style: GoogleFonts.nunito(
                      color: WelcomeStyle.cardSubtitle,
                      fontSize: 10.5 * scale,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / 56;
        final dotSize = 8 * scale;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IndicatorDot(color: WelcomeStyle.inactiveDot, size: dotSize),
            SizedBox(width: 8 * scale),
            Container(
              width: 24 * scale,
              height: dotSize,
              decoration: BoxDecoration(
                color: WelcomeStyle.coral,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            SizedBox(width: 8 * scale),
            _IndicatorDot(color: WelcomeStyle.inactiveDot, size: dotSize),
          ],
        );
      },
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
