import 'package:flutter/services.dart';

import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/core/utils/phone/phone_input_formatter.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

class LoginNameInputFormatter extends TextInputFormatter {
  const LoginNameInputFormatter(this.region);

  final PhoneRegion region;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final kind = detectLoginNameKind(newValue.text);
    if (kind != LoginNameKind.email) {
      return PhoneInputFormatter(region).formatEditUpdate(oldValue, newValue);
    }

    final text = newValue.text.replaceAll(RegExp(r'\s'), '');
    return TextEditingValue(
      text: text,
      selection: _selectionWithoutWhitespace(newValue.selection, newValue.text),
    );
  }

  TextSelection _selectionWithoutWhitespace(
    TextSelection selection,
    String value,
  ) {
    int offsetFor(int offset) => value
        .substring(0, offset.clamp(0, value.length))
        .replaceAll(RegExp(r'\s'), '')
        .length;

    return selection.copyWith(
      baseOffset: offsetFor(selection.baseOffset),
      extentOffset: offsetFor(selection.extentOffset),
    );
  }
}
