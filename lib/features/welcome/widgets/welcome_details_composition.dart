import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi_flutter/core/theme/font_size.dart';

import 'package:numi_flutter/features/welcome/widgets/numi_brand_text.dart';
import 'package:numi_flutter/features/welcome/widgets/welcome_start_button.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';

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
        final canvasLeft = (width - canvasWidth) / 2;
        final topPadding = math.max(0.0, (height - _designHeight * scale) / 2);
        final bottomSafe = MediaQuery.paddingOf(context).bottom;

        double s(double value) => value * scale;
        final controlsHeight = s(42);
        final controlsBottom = math.max(bottomSafe + s(22), s(30));
        final gridGap = s(12);
        final gridHeight = s(132) * 2 + gridGap;
        final gridBottom = controlsBottom + controlsHeight + s(35);
        final logoTop = math.max(topPadding + s(18), s(14));
        final heroTop = math.max(topPadding + s(78), s(68));

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
                        AppColors.pageBackgroundTop,
                        AppColors.pageBackground,
                        Colors.white,
                      ],
                      stops: [0, 0.42, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: canvasLeft + s(-128),
                top: heroTop,
                width: s(540),
                height: s(360),
                child: IgnorePointer(
                  child: Image.asset(_heroAsset, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                left: canvasLeft + s(16),
                top: logoTop,
                width: s(156),
                height: s(32),
                child: _BrandLogo(onTap: onBack),
              ),
              Positioned(
                left: canvasLeft + s(16),
                bottom: gridBottom,
                width: canvasWidth - s(32),
                height: gridHeight,
                child: _FeatureGrid(scale: scale),
              ),
              Positioned(
                left: canvasLeft + s(24),
                bottom: controlsBottom,
                width: canvasWidth - s(39),
                height: controlsHeight,
                child: Row(
                  children: [
                    SizedBox(
                      width: s(56),
                      height: s(8),
                      child: const _PageIndicator(),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: s(143),
                      height: controlsHeight,
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

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final cardWidth = 156 * scale;
    final cardHeight = 132 * scale;
    final gap = 12 * scale;

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: const _FeatureCard(
                imageAsset: WelcomeDetailsComposition._teacherAsset,
                imageSize: 54,
                title: 'Đánh Giá',
                subtitle: 'Đánh giá năng lực',
              ),
            ),
            SizedBox(width: gap),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: const _FeatureCard(
                imageAsset: WelcomeDetailsComposition._assessmentAsset,
                imageSize: 54,
                title: 'Học Toán',
                subtitle: 'Đến lớp 5',
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        Row(
          children: [
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: const _FeatureCard(
                imageAsset: WelcomeDetailsComposition._progressAsset,
                imageSize: 54,
                title: 'Phụ Huynh/GV',
                subtitle: 'Theo dõi tiến độ',
              ),
            ),
            SizedBox(width: gap),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: const _FeatureCard(
                imageAsset: WelcomeDetailsComposition._gameAsset,
                imageSize: 54,
                title: 'Game Toán',
                subtitle: 'Chơi và học',
              ),
            ),
          ],
        ),
      ],
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
                  firstColor: AppColors.welcomeDeepTeal,
                  secondColor: AppColors.coral500,
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
              14 * scale,
              12 * scale,
              10 * scale,
            ),
            child: Column(
              children: [
                Image.asset(
                  imageAsset,
                  width: imageSize * scale,
                  height: imageSize * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 8 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.nunito(
                      color: AppColors.welcomeTitle,
                      fontSize: FontSize.normal,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 4 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    style: GoogleFonts.nunito(
                      color: AppColors.textSlate,
                      fontSize: FontSize.small,
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
            _IndicatorDot(color: AppColors.inactiveDot, size: dotSize),
            SizedBox(width: 8 * scale),
            Container(
              width: 24 * scale,
              height: dotSize,
              decoration: BoxDecoration(
                color: AppColors.coral600,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            SizedBox(width: 8 * scale),
            _IndicatorDot(color: AppColors.inactiveDot, size: dotSize),
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
