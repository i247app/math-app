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
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),

                          // Mascot Graphics
                          Image.asset(
                            _mascotAsset,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),

                          // Brand text
                          const NumiBrandText(fontSize: 42.0),

                          // This spacer natively pushes everything down to the background curves
                          const Spacer(),

                          // Book Illustration
                          Image.asset(
                            _booksAsset,
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),

                          // Button action hub
                          Padding(
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