import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/phone_input_formatter.dart';
import 'package:numi/features/auth/phone_region.dart';
import 'package:numi/features/auth/widgets/login/login_action_button.dart';
import 'package:numi/features/auth/widgets/login/phone_region_menu.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.controller,
    required this.region,
    required this.onRegionChanged,
    required this.onSendOtp,
    required this.actionLabel,
    required this.isSendingOtp,
    required this.isCheckingAuthPhone,
    required this.canSendOtp,
    required this.canLoginWithPin,
    required this.onLoginWithPin,
    required this.onPhoneChanged,
    this.phoneErrorText,
  });

  final TextEditingController controller;
  final PhoneRegion region;
  final ValueChanged<PhoneRegion> onRegionChanged;
  final VoidCallback onSendOtp;
  final String actionLabel;
  final bool isSendingOtp;
  final bool isCheckingAuthPhone;
  final bool canSendOtp;
  final bool canLoginWithPin;
  final VoidCallback onLoginWithPin;
  final ValueChanged<String> onPhoneChanged;
  final String? phoneErrorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.inputSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.borderStrong, width: 1.5),
          ),
          child: Row(
            children: [
              PhoneRegionMenu(region: region, onChanged: onRegionChanged),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(width: 1, height: 24, color: colors.border),
              ),
              Expanded(
                child: TextField(
                  key: ValueKey(region),
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  autofillHints: null,
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  smartDashesType: SmartDashesType.disabled,
                  smartQuotesType: SmartQuotesType.disabled,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    PhoneInputFormatter(region),
                  ],
                  onChanged: onPhoneChanged,
                  decoration: InputDecoration(
                    hintText: region.hint,
                    hintStyle: GoogleFonts.andika(
                      color: colors.inputHint,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: GoogleFonts.andika(
                    color: colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: phoneErrorText == null
              ? const SizedBox(height: 24)
              : Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Text(
                    phoneErrorText!,
                    style: TextStyle(
                      color: colors.error,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
        LoginActionButton(
          label: actionLabel,
          onPressed: canSendOtp && !isCheckingAuthPhone && !isSendingOtp
              ? onSendOtp
              : null,
          isBusy: canSendOtp && (isCheckingAuthPhone || isSendingOtp),
        ),
        SizedBox(
          height: 76,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: canLoginWithPin
                ? Center(
                    key: const ValueKey('login-with-pin'),
                    child: InkWell(
                      onTap: onLoginWithPin,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 18,
                        ),
                        child: Text(
                          context.getText(AppKeys.loginWithPin),
                          style: GoogleFonts.andika(
                            color: colors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 20 / 16,
                            decoration: TextDecoration.underline,
                            decorationColor: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-pin-login')),
          ),
        ),
      ],
    );
  }
}
