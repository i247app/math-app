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
    this.labelText,
    this.fontSize = FontSize.large,
    this.cornerRadius = 28,
    this.verticalPadding = 16,
  });

  final VoidCallback onStart;
  final String labelKey;
  final String? labelText;
  final double fontSize;
  final double cornerRadius;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    final radius = BorderRadius.circular(cornerRadius);

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
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                labelText ?? context.getText(labelKey),
                style: GoogleFonts.nunito(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: fontSize,
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
