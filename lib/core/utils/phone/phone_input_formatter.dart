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
      selection: _formattedSelection(newValue.selection, newValue.text, text),
    );
  }

  TextSelection _formattedSelection(
    TextSelection selection,
    String value,
    String formattedValue,
  ) {
    int offsetFor(int offset) {
      final prefix = value.substring(0, offset.clamp(0, value.length));
      final digitsBeforeCursor = prefix.replaceAll(RegExp(r'\D'), '').length;
      var formattedOffset = 0;
      var digitCount = 0;
      while (formattedOffset < formattedValue.length &&
          digitCount < digitsBeforeCursor) {
        if (RegExp(r'\d').hasMatch(formattedValue[formattedOffset])) {
          digitCount++;
        }
        formattedOffset++;
      }

      // Keep a cursor placed after an existing separator after that separator.
      if (prefix.isNotEmpty &&
          RegExp(r'\D').hasMatch(prefix[prefix.length - 1])) {
        while (formattedOffset < formattedValue.length &&
            RegExp(r'\D').hasMatch(formattedValue[formattedOffset])) {
          formattedOffset++;
        }
      }
      return formattedOffset;
    }

    return selection.copyWith(
      baseOffset: offsetFor(selection.baseOffset),
      extentOffset: offsetFor(selection.extentOffset),
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
