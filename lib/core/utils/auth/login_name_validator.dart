import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/phone/phone_number_validator.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

enum LoginNameKind { phone, email }

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final RegExp _emailInitialLetter = RegExp(r'^[A-Za-z]');

bool isValidEmailInput(String rawValue) {
  return emailInputErrorKey(rawValue) == null;
}

/// App policy: email addresses must begin with an ASCII letter. This is a
/// product constraint, not a restriction shared by all email providers.
String? emailInputErrorKey(String rawValue) {
  final value = rawValue.trim();
  if (value.isNotEmpty && !_emailInitialLetter.hasMatch(value)) {
    return AppKeys.emailMustStartWithLetter;
  }
  return _emailPattern.hasMatch(value) ? null : AppKeys.invalidEmail;
}

class LoginNameValidationResult {
  const LoginNameValidationResult({
    required this.loginName,
    required this.kind,
    required this.errorKey,
    this.phoneRegion,
    this.phonePreviewRegion,
  });

  const LoginNameValidationResult.empty()
    : loginName = null,
      kind = null,
      errorKey = null,
      phoneRegion = null,
      phonePreviewRegion = null;

  final String? loginName;
  final LoginNameKind? kind;
  final String? errorKey;
  final PhoneRegion? phoneRegion;
  final PhoneRegion? phonePreviewRegion;

  bool get isValid => loginName != null && errorKey == null;
}

LoginNameKind? detectLoginNameKind(
  String rawValue, {
  bool phoneOnly = false,
  bool emailOnly = false,
}) {
  final value = rawValue.trim();
  if (value.isEmpty) {
    return null;
  }
  if (emailOnly) {
    return LoginNameKind.email;
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
  bool emailOnly = false,
  bool inferPhoneRegion = false,
}) {
  final value = rawValue.trim();
  final kind = detectLoginNameKind(
    value,
    phoneOnly: phoneOnly,
    emailOnly: emailOnly,
  );
  if (kind == null) {
    return const LoginNameValidationResult.empty();
  }

  if (kind == LoginNameKind.email) {
    final errorKey = emailInputErrorKey(value);
    return LoginNameValidationResult(
      loginName: errorKey == null ? value : null,
      kind: kind,
      errorKey: errorKey,
    );
  }

  final detectedRegion = detectPhoneRegion(
    value,
    preferredRegion: inferPhoneRegion ? null : region,
  );
  final previewRegion = previewPhoneRegion(
    value,
    preferredRegion: inferPhoneRegion ? null : region,
  );
  var validationRegion = detectedRegion ?? previewRegion ?? region;
  if (value.startsWith('+')) {
    final compact = value.replaceAll(RegExp(r'[\s()-]'), '');
    for (final candidate in PhoneRegion.values) {
      if (compact.startsWith(candidate.code)) validationRegion = candidate;
    }
  }
  final phone = normalizePhoneInput(validationRegion, value);
  return LoginNameValidationResult(
    loginName: phone.phone,
    kind: kind,
    errorKey: phone.errorKey,
    phoneRegion: detectedRegion,
    phonePreviewRegion: previewRegion,
  );
}
