import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/auth/login_name_input_formatter.dart';
import 'package:numi/core/utils/phone/phone_input_formatter.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/widgets/login/login_action_button.dart';
import 'package:numi/features/auth/widgets/login/phone_region_menu.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.controller,
    required this.region,
    required this.isSignupEntry,
    required this.showPhoneRegion,
    required this.onRegionChanged,
    required this.onSendOtp,
    required this.actionLabel,
    required this.isSendingOtp,
    required this.isCheckingLoginName,
    required this.canSendOtp,
    required this.canLoginWithPin,
    required this.onLoginWithPin,
    required this.onLoginNameChanged,
    this.loginNameErrorText,
  });

  final TextEditingController controller;
  final PhoneRegion region;
  final bool isSignupEntry;
  final bool showPhoneRegion;
  final ValueChanged<PhoneRegion> onRegionChanged;
  final VoidCallback onSendOtp;
  final String actionLabel;
  final bool isSendingOtp;
  final bool isCheckingLoginName;
  final bool canSendOtp;
  final bool canLoginWithPin;
  final VoidCallback onLoginWithPin;
  final ValueChanged<String> onLoginNameChanged;
  final String? loginNameErrorText;

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
              if (showPhoneRegion) ...[
                PhoneRegionMenu(region: region, onChanged: onRegionChanged),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(width: 1, height: 24, color: colors.border),
                ),
              ],
              Expanded(
                child: TextField(
                  key: ValueKey(
                    '${region.name}-${isSignupEntry ? 'signup' : 'login'}',
                  ),
                  controller: controller,
                  keyboardType: isSignupEntry
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  autofillHints: null,
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  smartDashesType: SmartDashesType.disabled,
                  smartQuotesType: SmartQuotesType.disabled,
                  inputFormatters: isSignupEntry
                      ? <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          PhoneInputFormatter(region),
                        ]
                      : <TextInputFormatter>[LoginNameInputFormatter(region)],
                  onChanged: onLoginNameChanged,
                  decoration: InputDecoration(
                    hintText: isSignupEntry
                        ? region.hint
                        : context.getText(AppKeys.loginNameHint),
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: colors.inputHint,
                      fontWeight: FontWeight.w500,
                      fontSize: FontSize.large,
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
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: colors.textPrimary,
                    fontSize: FontSize.xl,
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
          child: loginNameErrorText == null
              ? const SizedBox(height: 24)
              : Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Text(
                    loginNameErrorText!,
                    key: const ValueKey('login-name-error'),
                    style: TextStyle(
                      color: colors.error,
                      fontSize: FontSize.xs,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
        LoginActionButton(
          label: actionLabel,
          onPressed: canSendOtp && !isCheckingLoginName && !isSendingOtp
              ? onSendOtp
              : null,
          isBusy: canSendOtp && (isCheckingLoginName || isSendingOtp),
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
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: colors.textPrimary,
                                fontSize: FontSize.normal,
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
