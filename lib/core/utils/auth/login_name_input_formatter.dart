import 'package:flutter/services.dart';

/// Caps all-digit input while allowing the shared field to accept email text.
class LoginNameInputFormatter extends TextInputFormatter {
  final _digitsOnly = RegExp(r'^[0-9]+$');
  final _numberLimit = LengthLimitingTextInputFormatter(
    10,
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!_digitsOnly.hasMatch(newValue.text)) return newValue;
    return _numberLimit.formatEditUpdate(oldValue, newValue);
  }
}
