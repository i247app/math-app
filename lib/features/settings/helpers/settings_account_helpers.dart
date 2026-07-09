import 'package:numi/features/auth/otp_auth_api.dart';

String settingsFallbackUsername(LoginUser? user) {
  final name = user?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }

  final email = user?.email?.trim();
  if (email != null && email.isNotEmpty) {
    return email.split('@').first;
  }

  return 'alex_parent';
}

String settingsDisplayPhone(String? value, {String fallback = '090 123 4567'}) {
  final phone = value?.trim();
  if (phone == null || phone.isEmpty) {
    return fallback;
  }

  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('84') && digits.length > 2) {
    return settingsFormatLocalPhone('0${digits.substring(2)}');
  }

  return settingsFormatLocalPhone(digits);
}

String? settingsNormalizedPhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.isEmpty ? null : digits;
}

String? settingsEmptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String settingsFormatLocalPhone(String digits) {
  if (digits.length == 10 && digits.startsWith('0')) {
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} '
        '${digits.substring(6)}';
  }

  return digits;
}
