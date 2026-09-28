import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/utils/phone/phone_input_formatter.dart';
import 'package:numi/core/utils/phone/phone_number_validator.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/helpers/identifier_check_response.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_action_button.dart';
import 'package:numi/features/auth/widgets/auth_layout.dart';
import 'package:numi/features/auth/widgets/signup/signup_phone_input.dart';
import 'package:numi/features/welcome/widgets/numi_brand_text.dart';

/// Reserved signup screen for phone number entry.
///
/// Checks availability and sends signup OTP before notifying [onOtpSent].
/// This screen is not registered in app navigation yet.
class SignupWithPhone extends StatefulWidget {
  const SignupWithPhone({
    super.key,
    required this.onBack,
    required this.authService,
    required this.onOtpSent,
    this.isSubmitting = false,
  });

  final VoidCallback onBack;
  final AuthService authService;
  final ValueChanged<String> onOtpSent;
  final bool isSubmitting;

  // TODO: Wire this screen and onOtpSent to a complete phone registration flow
  // when phone account creation is supported.

  @override
  State<SignupWithPhone> createState() => _SignupWithPhoneState();
}

class _SignupWithPhoneState extends State<SignupWithPhone> {
  final _phoneController = TextEditingController();
  PhoneRegion _region = PhoneRegion.vn;
  String? _errorKey;
  bool _isSubmitting = false;

  bool get _isBusy => widget.isSubmitting || _isSubmitting;

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
    if (_isBusy || region == _region) {
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

  Future<void> _submit() async {
    if (_isBusy) {
      return;
    }
    final result = normalizePhoneInput(_region, _phoneController.text);
    if (!result.isValid) {
      setState(() => _errorKey = result.errorKey ?? AppKeys.phoneRequired);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final phone = result.phone!;
    setState(() {
      _isSubmitting = true;
      _errorKey = null;
    });

    String? errorKey;
    var otpSent = false;
    var checkingIdentifier = true;
    try {
      final response = await widget.authService.checkIdentifier(phone);
      if (!mounted) return;
      final availability = IdentifierAvailability.fromResponse(response, phone);
      if (availability == null) {
        errorKey = AppKeys.authPhoneCheckFailed;
      } else if (availability.mstatus != 200) {
        errorKey = AppKeys.signupPhoneAlreadyRegistered;
      } else if (availability.otpEnabled != true) {
        errorKey = AppKeys.signupOtpUnavailable;
      } else {
        checkingIdentifier = false;
        await widget.authService.sendOtp(
          loginName: phone,
          kind: AuthOtpKind.signup,
        );
        otpSent = true;
      }
    } catch (_) {
      errorKey = checkingIdentifier
          ? AppKeys.authPhoneCheckFailed
          : AppKeys.signupOtpFailed;
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _errorKey = errorKey;
    });
    if (otpSent) widget.onOtpSent(phone);
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
              enabled: !_isBusy,
              errorText: _errorKey == null ? null : context.getText(_errorKey!),
            ),
            const SizedBox(height: 24),
            AuthEntryActionButton(
              label: context.getText(AppKeys.signup),
              onPressed: _isBusy ? null : _submit,
              isBusy: _isBusy,
            ),
          ],
        ),
      ),
    );
  }
}
