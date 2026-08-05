import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class WelcomeDetailsFeatureGrid extends StatelessWidget {
  const WelcomeDetailsFeatureGrid({super.key});

  static const _assetPrefix = 'assets/images/';
  static const _assessmentAsset = '${_assetPrefix}welcome-card-assessment.png';
  static const _teacherAsset =
      '${_assetPrefix}welcome-card-teacher-support.png';
  static const _progressAsset =
      '${_assetPrefix}welcome-card-progress-tracking.png';
  static const _gameAsset = '${_assetPrefix}welcome-card-game-learning.png';

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
            imageAsset: _teacherAsset,
            title: context.getText(AppKeys.welcomeAssessmentTitle),
            subtitle: context.getText(AppKeys.welcomeAssessmentSubtitle),
          ),
          _FeatureCard(
            imageAsset: _assessmentAsset,
            title: context.getText(AppKeys.welcomeLearnMathTitle),
            subtitle: context.getText(AppKeys.welcomeLearnMathSubtitle),
          ),
          _FeatureCard(
            imageAsset: _progressAsset,
            title: context.getText(AppKeys.welcomeParentTeacherTitle),
            subtitle: context.getText(AppKeys.welcomeParentTeacherSubtitle),
          ),
          _FeatureCard(
            imageAsset: _gameAsset,
            title: context.getText(AppKeys.welcomeGamesTitle),
            subtitle: context.getText(AppKeys.welcomeGamesSubtitle),
          ),
        ],
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
