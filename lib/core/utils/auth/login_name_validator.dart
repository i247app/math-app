import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/phone/phone_number_validator.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

enum LoginNameKind { phone, email }

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

bool isValidEmailInput(String rawValue) {
  return _emailPattern.hasMatch(rawValue.trim());
}

class LoginNameValidationResult {
  const LoginNameValidationResult({
    required this.loginName,
    required this.kind,
    required this.errorKey,
  });

  const LoginNameValidationResult.empty()
    : loginName = null,
      kind = null,
      errorKey = null;

  final String? loginName;
  final LoginNameKind? kind;
  final String? errorKey;

  bool get isValid => loginName != null && errorKey == null;
}

LoginNameKind? detectLoginNameKind(String rawValue, {bool phoneOnly = false}) {
  final value = rawValue.trim();
  if (value.isEmpty) {
    return null;
  }
  if (phoneOnly) {
    return LoginNameKind.phone;
  }
  return RegExp(r'^[0-9\s+()-]+$').hasMatch(value)
      ? LoginNameKind.phone
      : LoginNameKind.email;
}

LoginNameValidationResult normalizeLoginNameInput(
  PhoneRegion region,
  String rawValue, {
  bool phoneOnly = false,
}) {
  final value = rawValue.trim();
  final kind = detectLoginNameKind(value, phoneOnly: phoneOnly);
  if (kind == null) {
    return const LoginNameValidationResult.empty();
  }

  if (kind == LoginNameKind.email) {
    final isValidEmail = isValidEmailInput(value);
    return LoginNameValidationResult(
      loginName: isValidEmail ? value : null,
      kind: kind,
      errorKey: isValidEmail ? null : AppKeys.invalidEmail,
    );
  }

  final phone = normalizePhoneInput(region, value);
  return LoginNameValidationResult(
    loginName: phone.phone,
    kind: kind,
    errorKey: phone.errorKey,
  );
}
