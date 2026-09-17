import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class WelcomeStartButton extends StatelessWidget {
  const WelcomeStartButton({
    super.key,
    required this.onStart,
    this.labelKey = AppKeys.start,
  });

  final VoidCallback onStart;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    final radius = BorderRadius.circular(28);

    return Material(
      color: colors.accent,
      borderRadius: radius,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onStart();
        },
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.getText(labelKey),
                style: GoogleFonts.nunito(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: FontSize.large,
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
