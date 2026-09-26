import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

import 'numi_brand_text.dart';
import 'welcome_background.dart';
import 'welcome_login_button.dart';
import 'welcome_start_button.dart';
import 'welcome_thinking_scene.dart';

class WelcomeComposition extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onAssessment;
  final VoidCallback onLogin;

  const WelcomeComposition({
    super.key,
    required this.onStart,
    required this.onAssessment,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textScaler = MediaQuery.textScalerOf(context);
    final safePadding = MediaQuery.paddingOf(context);

    return Stack(
      children: [
        const Positioned.fill(child: WelcomeBackground()),
        LayoutBuilder(
          builder: (context, constraints) {
            final sceneWidth = math.min(constraints.maxWidth, 420.0);
            final sceneHeight = sceneWidth * 300 / 360;
            // Reserve enough space for enlarged text and short viewports.
            final minimumHeight =
                sceneHeight +
                textScaler.scale(40) * 1.2 +
                textScaler.scale(18) * 3.7 +
                textScaler.scale(16) * 1.2 +
                180 +
                safePadding.vertical;

            return SingleChildScrollView(
              key: const ValueKey('welcome-scroll'),
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: math.max(constraints.maxHeight, minimumHeight),
                child: Column(
                  children: [
                    const Spacer(flex: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: NumiBrandText(
                              fontSize: 40,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: context.getText(
                                    AppKeys.welcomeTaglineMath,
                                  ),
                                ),
                                TextSpan(
                                  text: 'AI',
                                  style: TextStyle(color: colors.accentStrong),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'NunitoVariable',
                              color: colors.brand,
                              fontSize: 18,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            context.getText(
                              AppKeys.welcomeTaglineStudyAssessment,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'NunitoVariable',
                              color: colors.brand,
                              fontSize: 18,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 11),
                    SizedBox(
                      width: sceneWidth,
                      height: sceneHeight,
                      child: WelcomeThinkingScene(onTry: onAssessment),
                    ),
                    const Spacer(flex: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: math.min(280, constraints.maxWidth * 0.64),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            WelcomeStartButton(
                              key: const ValueKey('welcome-login-action'),
                              onStart: onLogin,
                              labelKey: AppKeys.welcomeLogin,
                              cornerRadius: 20,
                              verticalPadding: 14,
                              fitLabel: true,
                            ),
                            const SizedBox(height: 4),
                            WelcomeLoginButton(
                              key: const ValueKey('welcome-signup-action'),
                              onLogin: onStart,
                              labelKey: AppKeys.welcomeSignup,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
