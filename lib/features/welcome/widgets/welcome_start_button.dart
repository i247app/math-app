import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';

class WelcomeStartButton extends StatelessWidget {
  const WelcomeStartButton({
    super.key,
    required this.onStart,
    required this.scale,
    this.labelKey = AppKeys.continueLabel,
  });

  final VoidCallback onStart;
  final double scale;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20 * scale);

    return Material(
      color: AppColors.coral600,
      borderRadius: radius,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onStart();
        },
        borderRadius: radius,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.getText(labelKey),
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
