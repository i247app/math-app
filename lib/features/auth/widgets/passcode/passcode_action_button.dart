import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/widgets/auth_action_button.dart';

class PasscodeActionButton extends StatelessWidget {
  const PasscodeActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return AuthActionButton(
      label: label,
      onPressed: onPressed,
      layout: AuthActionButtonLayout.compact,
      isBusy: isBusy,
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
