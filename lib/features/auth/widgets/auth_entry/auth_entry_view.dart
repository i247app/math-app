import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/controllers/auth_state.dart';
import 'package:numi/features/auth/widgets/auth_layout.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_card.dart';
import 'package:numi/features/welcome/widgets/numi_brand_text.dart';

class AuthEntryBindings {
  const AuthEntryBindings({
    required this.controller,
    required this.region,
    required this.showPhoneRegion,
    required this.onRegionChanged,
    required this.onBack,
    required this.onSubmitIdentifier,
    required this.isSubmitting,
    required this.isCheckingIdentifier,
    required this.canSubmit,
    required this.canLoginWithPin,
    required this.onLoginWithPin,
    required this.onSwitchEntryMode,
    required this.onIdentifierChanged,
    this.identifierErrorText,
  });

  final TextEditingController controller;
  final PhoneRegion region;
  final bool showPhoneRegion;
  final ValueChanged<PhoneRegion> onRegionChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmitIdentifier;
  final bool isSubmitting;
  final bool isCheckingIdentifier;
  final bool canSubmit;
  final bool canLoginWithPin;
  final VoidCallback onLoginWithPin;
  final VoidCallback onSwitchEntryMode;
  final ValueChanged<String> onIdentifierChanged;
  final String? identifierErrorText;
}

class AuthEntryView extends StatelessWidget {
  const AuthEntryView({super.key, required this.bindings, required this.mode});

  final AuthEntryBindings bindings;
  final AuthEntryMode mode;

  @override
  Widget build(BuildContext context) {
    final entry = bindings;
    return AuthLayout(
      onBack: entry.onBack,
      titleWidget: const NumiBrandText(fontSize: FontSize.displayLarge),
      fillRemainingBody: true,
      bodyGap: 54,
      bodyBuilder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38),
            child: AuthEntryCard(
              controller: entry.controller,
              region: entry.region,
              mode: mode,
              showPhoneRegion: entry.showPhoneRegion,
              onRegionChanged: entry.onRegionChanged,
              onSubmitIdentifier: entry.onSubmitIdentifier,
              actionLabel: context.getText(
                mode == AuthEntryMode.signup ? AppKeys.signup : AppKeys.login,
              ),
              isSubmitting: entry.isSubmitting,
              isCheckingIdentifier: entry.isCheckingIdentifier,
              canSubmit: entry.canSubmit,
              canLoginWithPin: entry.canLoginWithPin,
              onLoginWithPin: entry.onLoginWithPin,
              onIdentifierChanged: entry.onIdentifierChanged,
              identifierErrorText: entry.identifierErrorText,
            ),
          ),
          const Spacer(),
          Center(
            child: _AuthEntrySwitchPrompt(
              mode: mode,
              onSwitch: entry.onSwitchEntryMode,
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _AuthEntrySwitchPrompt extends StatelessWidget {
  const _AuthEntrySwitchPrompt({required this.mode, required this.onSwitch});

  final AuthEntryMode mode;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final promptKey = mode == AuthEntryMode.signup
        ? AppKeys.authSwitchToLoginPrompt
        : AppKeys.authSwitchToSignupPrompt;
    final actionKey = mode == AuthEntryMode.signup
        ? AppKeys.login
        : AppKeys.signup;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          context.getText(promptKey),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: colors.textSecondary,
            fontSize: FontSize.normal,
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
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: colors.brandStrong,
                fontSize: FontSize.normal,
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
