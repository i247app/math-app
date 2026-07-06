import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/auth/phone_region.dart';
import 'package:numi_flutter/features/auth/widgets/auth_anchored_layout.dart';
import 'package:numi_flutter/features/auth/widgets/login/login_card.dart';

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
    return AuthAnchoredLayout(
      onBack: onBack,
      fillRemainingBody: true,
      compactBodyGap: 32,
      regularBodyGap: 32,
      mascotShadowBlur: 30,
      mascotShadowOffset: const Offset(0, 15),
      bodyBuilder: (context, compact) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
            color: const Color(0xFF6B7477),
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
                color: const Color(0xFF339395),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.25,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF339395),
                decorationThickness: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
