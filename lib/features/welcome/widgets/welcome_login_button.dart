import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/welcome/widgets/welcome_style.dart';

class WelcomeLoginButton extends StatelessWidget {
  const WelcomeLoginButton({
    super.key,
    required this.onLogin,
    required this.scale,
    this.labelKey = AppKeys.continueLabel,
  });

  final VoidCallback onLogin;
  final double scale;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onLogin();
        },
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 6 * scale,
          ),
          child: Text(
            context.getText(labelKey),
            style: GoogleFonts.nunito(
              color: WelcomeStyle.teal,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w500,
              height: 1.2,
              decorationColor: WelcomeStyle.teal,
              decorationThickness: 1.6,
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
        ),
      ),
    );
  }
}
