import 'package:flutter/services.dart';

import 'package:numi/core/utils/phone/phone_region.dart';

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
    final text = _formatInGroupsOfThree(clipped);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _formatInGroupsOfThree(String digits) {
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index == 3 || index == 6) {
        buffer.write(' ');
      }
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }
}
