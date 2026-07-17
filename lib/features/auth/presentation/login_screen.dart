import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/widgets/auth_layout.dart';
import 'package:numi/features/auth/widgets/login/login_card.dart';
import 'package:numi/features/welcome/widgets/numi_brand_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.controller,
    required this.region,
    required this.onRegionChanged,
    required this.onBack,
    required this.onSendOtp,
    required this.actionLabel,
    required this.isSignupEntry,
    required this.isSendingOtp,
    required this.isCheckingAuthPhone,
    required this.canSendOtp,
    required this.canLoginWithPin,
    required this.onLoginWithPin,
    required this.onSwitchEntryMode,
    required this.onPhoneChanged,
    this.phoneErrorText,
  });

  final TextEditingController controller;
  final PhoneRegion region;
  final ValueChanged<PhoneRegion> onRegionChanged;
  final VoidCallback onBack;
  final VoidCallback onSendOtp;
  final String actionLabel;
  final bool isSignupEntry;
  final bool isSendingOtp;
  final bool isCheckingAuthPhone;
  final bool canSendOtp;
  final bool canLoginWithPin;
  final VoidCallback onLoginWithPin;
  final VoidCallback onSwitchEntryMode;
  final ValueChanged<String> onPhoneChanged;
  final String? phoneErrorText;

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      onBack: onBack,
      titleWidget: const NumiBrandText(fontSize: 36),
      fillRemainingBody: true,
      bodyGap: 54,
      bodyBuilder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38),
            child: LoginCard(
              controller: controller,
              region: region,
              onRegionChanged: onRegionChanged,
              onSendOtp: onSendOtp,
              actionLabel: actionLabel,
              isSendingOtp: isSendingOtp,
              isCheckingAuthPhone: isCheckingAuthPhone,
              canSendOtp: canSendOtp,
              canLoginWithPin: canLoginWithPin,
              onLoginWithPin: onLoginWithPin,
              onPhoneChanged: onPhoneChanged,
              phoneErrorText: phoneErrorText,
            ),
          ),
          const Spacer(),
          Center(
            child: _AuthEntrySwitchPrompt(
              isSignupEntry: isSignupEntry,
              onSwitch: onSwitchEntryMode,
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _AuthEntrySwitchPrompt extends StatelessWidget {
  const _AuthEntrySwitchPrompt({
    required this.isSignupEntry,
    required this.onSwitch,
  });

  final bool isSignupEntry;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final promptKey = isSignupEntry
        ? AppKeys.authSwitchToLoginPrompt
        : AppKeys.authSwitchToSignupPrompt;
    final actionKey = isSignupEntry ? AppKeys.login : AppKeys.signup;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          context.getText(promptKey),
          style: GoogleFonts.andika(
            color: colors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        InkWell(
          onTap: onSwitch,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              context.getText(actionKey),
              style: GoogleFonts.andika(
                color: colors.brandStrong,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.25,
                decoration: TextDecoration.underline,
                decorationColor: colors.brandStrong,
                decorationThickness: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
