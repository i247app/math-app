import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/welcome/widgets/welcome_start_button.dart';

/// The guest assessment entry shown after the Welcome details carousel.
class WelcomeAssessmentIntroScreen extends StatelessWidget {
  const WelcomeAssessmentIntroScreen({
    super.key,
    required this.onAssessment,
    required this.onSkip,
  });

  static const _backgroundAsset =
      'assets/images/assessment_intro/assessment-intro-background.png';
  static const _logoAsset =
      'assets/images/assessment_intro/assessment-numi-logo.png';
  static const _mascotAsset =
      'assets/images/assessment_intro/assessment-graduate-mascot.png';

  final VoidCallback onAssessment;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colors.pageBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _backgroundAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final isTablet =
                      MediaQuery.sizeOf(context).shortestSide >= 600;
                  final logoWidth = math.min(
                    width * 0.65,
                    isTablet ? 315.0 : 240.0,
                  );
                  final mascotWidth = math.min(
                    width * (isTablet ? 0.58 : 0.7),
                    isTablet ? 390.0 : 310.0,
                  );

                  return Stack(
                    children: [
                      Positioned(
                        top: 2,
                        right: 12,
                        child: TextButton(
                          key: const ValueKey('welcome-assessment-skip'),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onSkip();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.welcomeTeal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            context.getText(AppKeys.skipUpper),
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: isTablet ? 80 : 72,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            _logoAsset,
                            width: logoWidth,
                            fit: BoxFit.contain,
                            semanticLabel: 'Numi Toán AI',
                          ),
                        ),
                      ),
                      Positioned(
                        top: math.max(height * 0.45, isTablet ? 310 : 270),
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            _mascotAsset,
                            width: mascotWidth,
                            fit: BoxFit.contain,
                            semanticLabel: 'Numi assessment mascot',
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: MediaQuery.viewPaddingOf(context).bottom + 96,
                        child: Center(
                          child: SizedBox(
                            width: math.min(width - 112, 240),
                            child: WelcomeStartButton(
                              key: const ValueKey(
                                'welcome-assessment-intro-action',
                              ),
                              onStart: onAssessment,
                              labelKey: AppKeys.assessmentAction,
                              cornerRadius: 16,
                              verticalPadding: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
