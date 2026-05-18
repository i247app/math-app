import 'package:flutter/services.dart';

import '../../features/onboarding/domain/phone_region.dart';

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter(this.region);

  final PhoneRegion region;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > region.maxDigits
        ? digits.substring(0, region.maxDigits)
        : digits;
    final text = switch (region) {
      PhoneRegion.vn => _formatVietnamNumber(clipped),
      PhoneRegion.us => _formatUsNumber(clipped),
    };

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _formatVietnamNumber(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String _formatUsNumber(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
