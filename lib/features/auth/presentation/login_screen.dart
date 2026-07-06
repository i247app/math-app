import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/auth/phone_region.dart';
import 'package:numi_flutter/features/auth/widgets/login/login_card.dart';
import 'package:numi_flutter/shared/widgets/common_widgets.dart';

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
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final mascotSize = width < 370 ? 160.0 : 200.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return ScreenFrame(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: SizedBox(
                height: math.max(constraints.maxHeight, compact ? 610 : 690),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: onBack,
                    ),
                    SizedBox(height: compact ? 12 : 24),
                    Center(
                      child: Container(
                        width: mascotSize,
                        height: mascotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/numi-mascot.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
              ),
            );
          },
        ),
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
