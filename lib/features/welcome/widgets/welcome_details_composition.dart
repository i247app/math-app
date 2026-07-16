import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/features/welcome/widgets/numi_brand_text.dart';
import 'package:numi/features/welcome/widgets/welcome_start_button.dart';

class WelcomeDetailsComposition extends StatelessWidget {
  const WelcomeDetailsComposition({
    super.key,
    required this.onStart,
    required this.onBack,
  });

  final VoidCallback onStart;
  final VoidCallback onBack;

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
    final colors = context.themeColors;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.pageBackgroundTop,
                  colors.pageBackground,
                  colors.surface,
                ],
                stops: const [0, 0.42, 1],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.noScaling),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 420,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _BrandLogo(onTap: onBack),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                height: isTablet ? 340 : 280,
                                width: double.infinity,
                                child: Image.asset(
                                  _heroAsset,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const Center(child: _FeatureGrid()),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 28,
                                  bottom:
                                      MediaQuery.paddingOf(context).bottom + 20,
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 420,
                                  ),
                                  child: Row(
                                    children: [
                                      const _PageIndicator(),
                                      const Spacer(),
                                      SizedBox(
                                        width: 143,
                                        child: WelcomeStartButton(
                                          onStart: onStart,
                                          scale: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 132,
        children: [
          _FeatureCard(
            imageAsset: WelcomeDetailsComposition._teacherAsset,
            title: context.getText(AppKeys.welcomeAssessmentTitle),
            subtitle: context.getText(AppKeys.welcomeAssessmentSubtitle),
          ),
          _FeatureCard(
            imageAsset: WelcomeDetailsComposition._assessmentAsset,
            title: context.getText(AppKeys.welcomeLearnMathTitle),
            subtitle: context.getText(AppKeys.welcomeLearnMathSubtitle),
          ),
          _FeatureCard(
            imageAsset: WelcomeDetailsComposition._progressAsset,
            title: context.getText(AppKeys.welcomeParentTeacherTitle),
            subtitle: context.getText(AppKeys.welcomeParentTeacherSubtitle),
          ),
          _FeatureCard(
            imageAsset: WelcomeDetailsComposition._gameAsset,
            title: context.getText(AppKeys.welcomeGamesTitle),
            subtitle: context.getText(AppKeys.welcomeGamesSubtitle),
          ),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              WelcomeDetailsComposition._mascotLogoAsset,
              width: 31,
              height: 31,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const NumiBrandText(fontSize: 20),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });

  final String imageAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        child: Column(
          children: [
            Image.asset(imageAsset, width: 54, height: 54, fit: BoxFit.contain),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: GoogleFonts.nunito(
                  color: colors.welcomeTitle,
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                maxLines: 1,
                style: GoogleFonts.nunito(
                  color: colors.textSecondary,
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
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IndicatorDot(color: colors.welcomeInactiveDot),
        const SizedBox(width: 8),
        Container(
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        _IndicatorDot(color: colors.welcomeInactiveDot),
      ],
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
