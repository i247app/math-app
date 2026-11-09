import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

final _phoneCharacters = RegExp(r'^\+?[0-9\s()-]+$');
final _usPhonePattern = RegExp(r'^[2-9]\d{2}[2-9]\d{6}$');
// Product default for otherwise unclassified nine-digit national input.
// This country hint does not establish a valid or assigned Vietnam number.
final _nineDigitCountryHintPattern = RegExp(r'^[1-9]\d{8}$');
// Mobile numbering ranges from Google's libphonenumber metadata:
// https://github.com/google/libphonenumber/blob/master/resources/PhoneNumberMetadata.xml
final _vietnamMobilePattern = RegExp(
  r'^(?:121[0-3]\d{5}|(?:1[46]0|(?:3\d|7[06-9])\d|5(?:[1689]\d|2[238]|59)|8(?:[1-8]\d|9[6-9])|9(?:[0-8]\d|9[013-9]))\d{6})$',
);

/// A complete phone candidate, never a commitment that changes the raw input.
PhoneRegion? detectPhoneRegion(
  String rawValue, {
  PhoneRegion? preferredRegion,
}) {
  final value = rawValue.trim();
  if (value.startsWith('+')) {
    for (final region in PhoneRegion.values) {
      if (normalizePhoneInput(region, value).isValid) return region;
    }
    return null;
  }
  for (final region
      in preferredRegion == null ? PhoneRegion.values : [preferredRegion]) {
    if (normalizePhoneInput(region, value).isValid) return region;
  }
  return null;
}

/// Country hint only. Submission still uses [normalizePhoneInput] to check the
/// supported numbering metadata; showing a flag is not number verification.
PhoneRegion? previewPhoneRegion(
  String rawValue, {
  PhoneRegion? preferredRegion,
}) {
  final supported = detectPhoneRegion(
    rawValue,
    preferredRegion: preferredRegion,
  );
  if (supported != null) return supported;
  final value = rawValue.trim();
  if (!value.startsWith('+') &&
      preferredRegion != null &&
      preferredRegion != PhoneRegion.vn) {
    return null;
  }
  if (!_phoneCharacters.hasMatch(value)) return null;
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (value.startsWith('+')) {
    final compact = value.replaceAll(RegExp(r'[\s()-]'), '');
    if (!compact.startsWith(PhoneRegion.vn.code)) return null;
    digits = digits.substring(2);
  } else if (digits.length > PhoneRegion.vn.maxDigits &&
      digits.startsWith('84')) {
    digits = digits.substring(2);
  }
  if (digits.length == 10 && digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  return _nineDigitCountryHintPattern.hasMatch(digits) ? PhoneRegion.vn : null;
}

class PhoneValidationResult {
  const PhoneValidationResult({required this.phone, required this.errorKey});

  const PhoneValidationResult.empty() : phone = null, errorKey = null;

  final String? phone;
  final String? errorKey;

  bool get isValid => phone != null && errorKey == null;
}

PhoneValidationResult normalizePhoneInput(
  PhoneRegion region,
  String rawDigits,
) {
  final value = rawDigits.trim();
  if (value.isEmpty) return const PhoneValidationResult.empty();
  if (value == '+' || region.code.startsWith(value)) {
    return const PhoneValidationResult(
      phone: null,
      errorKey: AppKeys.phoneTooShort,
    );
  }
  if (!_phoneCharacters.hasMatch(value)) {
    return const PhoneValidationResult(
      phone: null,
      errorKey: AppKeys.invalidPhone,
    );
  }
  var digits = rawDigits.replaceAll(RegExp(r'\D'), '');
  if (rawDigits.trimLeft().startsWith('+')) {
    final compact = rawDigits.replaceAll(RegExp(r'[\s()-]'), '');
    if (!compact.startsWith(region.code)) {
      return PhoneValidationResult(
        phone: null,
        errorKey: region.code.startsWith(compact)
            ? AppKeys.phoneTooShort
            : AppKeys.invalidPhone,
      );
    }
    digits = digits.substring(region.code.length - 1);
  } else if (digits.length > region.maxDigits &&
      digits.startsWith(region.code.substring(1))) {
    digits = digits.substring(region.code.length - 1);
  }
  if (digits.isEmpty) {
    return const PhoneValidationResult(
      phone: null,
      errorKey: AppKeys.invalidPhone,
    );
  }
  if (digits.length < region.minDigits) {
    return const PhoneValidationResult(
      phone: null,
      errorKey: AppKeys.phoneTooShort,
    );
  }
  if (digits.length > region.maxDigits) {
    return const PhoneValidationResult(
      phone: null,
      errorKey: AppKeys.invalidPhone,
    );
  }

  final nationalNumber = switch (region) {
    PhoneRegion.vn => _normalizeVietnamPhoneDigits(digits),
    PhoneRegion.us => _usPhonePattern.hasMatch(digits) ? digits : null,
  };
  if (nationalNumber == null || nationalNumber.isEmpty) {
    return const PhoneValidationResult(
      phone: null,
      errorKey: AppKeys.invalidPhone,
    );
  }
  return PhoneValidationResult(
    phone: '${region.code}$nationalNumber',
    errorKey: null,
  );
}

String? _normalizeVietnamPhoneDigits(String digits) {
  if (digits.length == 10) {
    if (!digits.startsWith('0')) return null;
    digits = digits.substring(1);
  }
  return _vietnamMobilePattern.hasMatch(digits) ? digits : null;
}
