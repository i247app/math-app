import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'numi_brand_text.dart';
import 'welcome_start_button.dart';
import 'welcome_login_button.dart';

class WelcomeComposition extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onLogin;

  static const _mascotAsset = 'assets/images/welcome_figma_mascot.png';
  static const _wavesAsset = 'assets/images/welcome_figma_waves.png';
  static const _booksAsset = 'assets/images/welcome_figma_books.png';

  const WelcomeComposition({
    super.key,
    required this.onStart,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND LAYER: Glued to the absolute bottom edge
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

          // 2. CONTENT LAYER: Scrollable container viewport to cleanly absorb tight screens
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
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
                          const NumiBrandText(fontSize: 42.0),

                          const SizedBox(height: 4),

                          // Math AI Subtitle
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(text: 'Math ', style: TextStyle(color: Color(0xFF2B8A9E))),
                                TextSpan(text: 'AI', style: TextStyle(color: Color(0xFFFF6B2C))),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Learning & Assessment Tagline
                          Text(
                            'Learning & Assessment',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: const Color(0xFF2B8A9E),
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Accent Orange Divider
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B2C),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // Restored the true Spacer! This expands aggressively to lock buttons to the bottom.
                          const Spacer(),

                          // Book Illustration
                          Image.asset(
                            _booksAsset,
                            height: isTablet ? 180 : 130,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),

                          // Button action hub - Tablet-safe, beautifully constrained layout
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 420, // Clean desktop/tablet capping width
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 56),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    WelcomeStartButton(
                                      onStart: onStart,
                                      scale: 1.0,
                                    ),
                                    const SizedBox(height: 16),
                                    WelcomeLoginButton(
                                      onLogin: onLogin,
                                      scale: 1.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Dynamically pads the baseline using the device safe area guidelines
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}