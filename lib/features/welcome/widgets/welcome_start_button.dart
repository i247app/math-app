import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class WelcomeStartButton extends StatelessWidget {
  const WelcomeStartButton({
    super.key,
    required this.onStart,
    required this.scale,
    this.labelKey = AppKeys.start,
  });

  final VoidCallback onStart;
  final double scale;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    // 1. INCREASED BORDER RADIUS FOR A TRUE SMOOTH PILL SHAPE
    final radius = BorderRadius.circular(28 * scale);

    return Material(
      color: colors.accent,
      borderRadius: radius,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onStart();
        },
        borderRadius: radius,
        // 2. ADDED INTERNAL VERTICAL PADDING TO CHUNK UP THE SIZE
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16 * scale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.getText(labelKey),
                style: GoogleFonts.nunito(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}