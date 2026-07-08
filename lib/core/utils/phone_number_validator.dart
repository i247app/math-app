import 'package:numi_flutter/features/auth/phone_region.dart';
import '../localization/app_keys.dart';

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
  final digits = rawDigits.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return const PhoneValidationResult.empty();
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
    PhoneRegion.us => digits.length == region.maxDigits ? digits : null,
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
  if (digits.length == 9) {
    return digits.startsWith('0') ? null : digits;
  }

  if (digits.length == 10) {
    return digits.startsWith('0') ? digits.substring(1) : null;
  }

  return null;
}
