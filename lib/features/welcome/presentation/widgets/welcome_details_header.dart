import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/welcome/presentation/widgets/numi_brand_text.dart';

class WelcomeDetailsHeader extends StatelessWidget {
  const WelcomeDetailsHeader({
    super.key,
    required this.onBack,
    required this.isTablet,
  });

  final VoidCallback onBack;
  final bool isTablet;

  static const _assetPrefix = 'assets/images/';
  static const _heroAsset = '${_assetPrefix}welcome-hero-math-friends.png';
  static const _mascotLogoAsset = '${_assetPrefix}welcome-logo-mascot.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
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
            child: Transform.translate(
              offset: const Offset(-32, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Image.asset(_heroAsset, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
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
              WelcomeDetailsHeader._mascotLogoAsset,
              width: 31,
              height: 31,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const NumiBrandText(fontSize: FontSize.xl),
          ],
        ),
      ),
    );
  }
}
