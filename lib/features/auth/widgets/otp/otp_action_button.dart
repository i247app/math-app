import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/widgets/auth_action_button.dart';

class OtpActionButton extends StatelessWidget {
  const OtpActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label.replaceAll('→', '').trim();

    return AuthActionButton(
      label: cleanLabel,
      onPressed: onPressed,
      layout: AuthActionButtonLayout.compact,
      uppercase: true,
      backgroundColor: AppColors.brandLogoOrange,
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.nunito(
        fontSize: FontSize.large,
        fontWeight: FontWeight.w900,
        height: 1.2,
      ),
    );
  }
}
