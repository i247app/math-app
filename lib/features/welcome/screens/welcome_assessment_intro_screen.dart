import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/welcome/widgets/welcome_start_button.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

/// The guest assessment entry shown after the Welcome details carousel.
class WelcomeAssessmentIntroScreen extends StatefulWidget {
  const WelcomeAssessmentIntroScreen({
    super.key,
    required this.onAssessment,
    required this.onSkip,
  });

  static const _backgroundAsset =
      'assets/images/assessment_intro/assessment-intro-background.png';
  static const _mascotAsset =
      'assets/images/assessment_intro/assessment-graduate-mascot.png';

  final Future<void> Function(BuildContext context) onAssessment;
  final VoidCallback onSkip;

  @override
  State<WelcomeAssessmentIntroScreen> createState() =>
      _WelcomeAssessmentIntroScreenState();
}

class _WelcomeAssessmentIntroScreenState
    extends State<WelcomeAssessmentIntroScreen> {
  bool _isStarting = false;

  Future<void> _startAssessment() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);
    try {
      await widget.onAssessment(context);
    } on NetworkException catch (error) {
      if (mounted) await context.showErrorDialog(error.message);
    } on FormatException {
      if (mounted) {
        await context.showErrorDialog(
          context.getText(AppKeys.invalidServerResponse),
        );
      }
    } catch (_) {
      if (mounted) {
        await context.showErrorDialog(
          context.getText(AppKeys.apiConnectionFailed),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

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
              WelcomeAssessmentIntroScreen._backgroundAsset,
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
                  final mascotWidth = math.min(
                    width * (isTablet ? 0.58 : 0.7),
                    isTablet ? 390.0 : 310.0,
                  );

                  return Stack(
                    children: [
                      Positioned(
                        top: 2,
                        left: 12,
                        child: AppBackButton(
                          key: const ValueKey('welcome-assessment-back'),
                          onPressed: () => Navigator.of(context).pop(),
                          color: AppColors.welcomeTeal,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 12,
                        child: TextButton(
                          key: const ValueKey('welcome-assessment-skip'),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onSkip();
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TOÁN AI',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'NunitoVariable',
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandTeal,
                                  fontSize: isTablet ? 52 : 42,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Kiểm Tra Năng Lực',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'NunitoVariable',
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.brandOrange,
                                    fontSize: isTablet ? 38 : 32,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: math.max(height * 0.45, isTablet ? 310 : 270),
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            WelcomeAssessmentIntroScreen._mascotAsset,
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
                            child: IgnorePointer(
                              ignoring: _isStarting,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  WelcomeStartButton(
                                    key: const ValueKey(
                                      'welcome-assessment-intro-action',
                                    ),
                                    onStart: () => _startAssessment(),
                                    labelText: 'START',
                                    fontSize: 32,
                                    cornerRadius: 16,
                                    verticalPadding: 14,
                                  ),
                                  if (_isStarting)
                                    const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                ],
                              ),
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
