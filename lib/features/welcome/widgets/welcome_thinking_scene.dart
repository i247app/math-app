import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';

class WelcomeThinkingScene extends StatelessWidget {
  const WelcomeThinkingScene({super.key, required this.onTry});

  final VoidCallback onTry;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 300,
        child: Stack(
          children: [
            Positioned(
              left: 113,
              top: 8,
              width: 250,
              height: 215,
              child: Image.asset(
                'assets/images/welcome-thinking.png',
                key: const ValueKey('welcome-thinking-cloud'),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
            Positioned(
              left: 155,
              top: 50,
              width: 164,
              height: 90,
              child: TextButton(
                key: const ValueKey('welcome-assessment-action'),
                onPressed: onTry,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: Text(
                  context.getText(AppKeys.welcomeTryIt),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // Keep both lines within the fixed cloud illustration.
                  textScaler: MediaQuery.textScalerOf(
                    context,
                  ).clamp(maxScaleFactor: 1.1),
                  style: GoogleFonts.nunito(
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 25,
              top: 133,
              width: 155,
              height: 163,
              child: Image.asset(
                'assets/images/welcome-thinking-owl.png',
                key: const ValueKey('welcome-thinking-mascot'),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
