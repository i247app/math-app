import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/utils/phone/phone_input_formatter.dart';
import 'package:numi/core/utils/phone/phone_number_validator.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_action_button.dart';
import 'package:numi/features/auth/widgets/auth_layout.dart';
import 'package:numi/features/auth/widgets/signup/signup_phone_input.dart';
import 'package:numi/features/welcome/widgets/numi_brand_text.dart';

/// Reserved signup screen for phone number entry.
///
/// Owns phone input and validation, then passes a normalized phone number to
/// [onSubmitPhone]. Account lookup, verification, and creation belong to the
/// future phone signup flow. This screen is not registered in navigation.
class SignupWithPhone extends StatefulWidget {
  const SignupWithPhone({
    super.key,
    required this.onBack,
    required this.onSubmitPhone,
    this.isSubmitting = false,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onSubmitPhone;
  final bool isSubmitting;

  // TODO: Connect this screen only after restoring phone signup API support.
  // Do not pass phone numbers to the current email signup controller.
  // Reserved usage example (intentionally not added to the app router):
  // SignupWithPhone(
  //   onBack: onBack,
  //   onSubmitPhone: onPhoneSignupRequested,
  //   isSubmitting: isPhoneSignupPending,
  // ),

  @override
  State<SignupWithPhone> createState() => _SignupWithPhoneState();
}

class _SignupWithPhoneState extends State<SignupWithPhone> {
  final _phoneController = TextEditingController();
  PhoneRegion _region = PhoneRegion.vn;
  String? _errorKey;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _clearError(String _) {
    if (_errorKey != null) {
      setState(() => _errorKey = null);
    }
  }

  void _selectRegion(PhoneRegion region) {
    if (widget.isSubmitting || region == _region) {
      return;
    }
    _phoneController.value = PhoneInputFormatter(
      region,
    ).formatEditUpdate(_phoneController.value, _phoneController.value);
    setState(() {
      _region = region;
      _errorKey = null;
    });
  }

  void _submit() {
    if (widget.isSubmitting) {
      return;
    }
    final result = normalizePhoneInput(_region, _phoneController.text);
    if (!result.isValid) {
      setState(() => _errorKey = result.errorKey ?? AppKeys.phoneRequired);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSubmitPhone(result.phone!);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      onBack: widget.onBack,
      titleWidget: const NumiBrandText(fontSize: FontSize.displayLarge),
      bodyGap: 54,
      bodyBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 38),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SignupPhoneInput(
              controller: _phoneController,
              region: _region,
              onRegionChanged: _selectRegion,
              onChanged: _clearError,
              onSubmitted: (_) => _submit(),
              enabled: !widget.isSubmitting,
              errorText: _errorKey == null ? null : context.getText(_errorKey!),
            ),
            const SizedBox(height: 24),
            AuthEntryActionButton(
              label: context.getText(AppKeys.signup),
              onPressed: widget.isSubmitting ? null : _submit,
              isBusy: widget.isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
