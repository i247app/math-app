import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

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
  }
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
