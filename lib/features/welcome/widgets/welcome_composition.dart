import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

import 'numi_brand_text.dart';
import 'welcome_login_button.dart';
import 'welcome_start_button.dart';

class WelcomeComposition extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onLogin;

  static const _mascotAsset = 'assets/images/welcome-figma-mascot.png';
  static const _wavesAsset = 'assets/images/welcome-figma-waves.png';
  static const _booksAsset = 'assets/images/welcome-figma-books.png';

  const WelcomeComposition({
    super.key,
    required this.onStart,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.pageBackground)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Image.asset(
            _wavesAsset,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: isTablet ? 48 : 24),

                          // Mascot Graphics
                          Image.asset(
                            _mascotAsset,
                            height: isTablet ? 220 : 160,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),

                          // Brand text
                          const NumiBrandText(),

                          const SizedBox(height: 4),

                          // Math AI Subtitle
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    fontSize: FontSize.headlineLarge,
                                    fontWeight: FontWeight.w600,
                                  ),
                              children: [
                                TextSpan(
                                  text: context.getText(
                                    AppKeys.welcomeTaglineMath,
                                  ),
                                  style: TextStyle(color: colors.brand),
                                ),
                                TextSpan(
                                  text: 'AI',
                                  style: TextStyle(color: colors.accentStrong),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Learning & Assessment Tagline
                          Text(
                            context.getText(
                              AppKeys.welcomeTaglineStudyAssessment,
                            ),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: colors.brand,
                              fontSize: FontSize.xl,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Accent Orange Divider
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.accentStrong,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            _booksAsset,
                            height: isTablet ? 180 : 130,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 56,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    WelcomeStartButton(onStart: onStart),
                                    const SizedBox(height: 16),
                                    WelcomeLoginButton(
                                      onLogin: onLogin,
                                      labelKey: AppKeys.welcomeLogin,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.paddingOf(context).bottom + 20,
                          ),
                        ],
                      ),
                    ],
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
