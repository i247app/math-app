import 'package:flutter/material.dart';
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = screenHeight > 700 ? 1.0 : 0.8;

    return Stack(
      children: [
        // 1. BACKGROUND LAYER: Waves anchored perfectly at the bottom
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

        // 2. FOREGROUND CONTENT LAYER: Wrapped in a Center to lock alignment
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Forces all children to center horizontally
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Mascot Graphic
                  Image.asset(
                    _mascotAsset,
                    height: screenHeight * 0.22 * scale,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),

                  // Core Typography Engine using Bagel Fat One
                  const NumiBrandText(),

                  const Spacer(flex: 3),

                  // The Books & Plants Illustration
                  Image.asset(
                    _booksAsset,
                    height: screenHeight * 0.18 * scale,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 28),

                  // 3. BUTTONS LAYOUT ZONE: Centered and constrained
                  SizedBox(
                    width: screenWidth * 0.68,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 56 * scale,
                          width: double.infinity,
                          child: WelcomeStartButton(
                            onStart: onStart,
                            scale: scale,
                          ),
                        ),
                        const SizedBox(height: 20),

                        WelcomeLoginButton(
                          onLogin: onLogin,
                          scale: scale,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}