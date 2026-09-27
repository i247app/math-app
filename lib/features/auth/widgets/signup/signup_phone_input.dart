import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/utils/phone/phone_input_formatter.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/widgets/auth_entry/phone_region_menu.dart';

/// Reserved phone input for a future phone signup flow.
///
/// Used only by the reserved `SignupWithPhone` screen, outside active navigation.
/// The caller owns the controller, selected region, and validation errors.
/// Normalize the formatted input with `normalizePhoneInput` before submission.
class SignupPhoneInput extends StatelessWidget {
  const SignupPhoneInput({
    super.key,
    required this.controller,
    required this.region,
    required this.onRegionChanged,
    required this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final PhoneRegion region;
  final ValueChanged<PhoneRegion> onRegionChanged;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;

  // TODO: Enable the reserved phone signup flow only after restoring phone
  // account creation and verification. Keep email signup navigation unchanged.
  // Reserved usage example:
  // SignupPhoneInput(
  //   controller: phoneController,
  //   region: selectedRegion,
  //   onRegionChanged: onPhoneRegionChanged,
  //   onChanged: onPhoneChanged,
  //   errorText: phoneErrorText,
  // ),

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
              IgnorePointer(
                ignoring: !enabled,
                child: PhoneRegionMenu(
                  region: region,
                  onChanged: onRegionChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(width: 1, height: 24, color: colors.border),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: <TextInputFormatter>[
                    PhoneInputFormatter(region),
                  ],
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    hintText: context.getText(AppKeys.phoneHint),
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: colors.inputHint,
                      fontWeight: FontWeight.w500,
                      fontSize: FontSize.large,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: colors.textPrimary,
                    fontSize: FontSize.xl,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: TextStyle(
              color: colors.error,
              fontSize: FontSize.xs,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}
