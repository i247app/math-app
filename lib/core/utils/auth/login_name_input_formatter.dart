import 'package:flutter/services.dart';

import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/core/utils/phone/phone_input_formatter.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

class LoginNameInputFormatter extends TextInputFormatter {
  LoginNameInputFormatter(
    this.region, {
    this.onRegionDetected,
    this.allowBareCountryInference = true,
  });

  PhoneRegion region;
  bool allowBareCountryInference;
  final void Function(PhoneRegion)? onRegionDetected;
  String _emailPrefix = '';
  String _lastFormattedText = '';
  bool _hasCountryCodeOnly = false;

  /// A typed calling code still selects phone input after moving to the menu.
  bool get hasCountryCodeOnly => _hasCountryCodeOnly;

  void reset() {
    _emailPrefix = '';
    _lastFormattedText = '';
    _hasCountryCodeOnly = false;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    _hasCountryCodeOnly = false;
    if (oldValue.text != _lastFormattedText ||
        !_isAppending(oldValue, newValue)) {
      _emailPrefix = '';
    }
    final kind = detectLoginNameKind(newValue.text);
    if (kind != LoginNameKind.email) {
      final prefix = _countryPrefix(oldValue, newValue);
      if (prefix != null) {
        final (detectedRegion, end) = prefix;
        _emailPrefix += newValue.text.substring(0, end);
        region = detectedRegion;
        onRegionDetected?.call(detectedRegion);
        newValue = newValue.copyWith(
          text: newValue.text.substring(end),
          selection: TextSelection(
            baseOffset: (newValue.selection.baseOffset - end).clamp(
              0,
              newValue.text.length - end,
            ),
            extentOffset: (newValue.selection.extentOffset - end).clamp(
              0,
              newValue.text.length - end,
            ),
          ),
          composing: TextRange.empty,
        );
      } else if (newValue.text.trimLeft().startsWith('+')) {
        // Keep incomplete or unsupported international codes visible. Stripping
        // the '+' here could submit them under the currently selected country.
        _lastFormattedText = newValue.text;
        return newValue;
      }
      final formatted = PhoneInputFormatter(region)
          .formatEditUpdate(oldValue, newValue);
      _hasCountryCodeOnly = prefix != null && formatted.text.isEmpty;
      _lastFormattedText = formatted.text;
      return formatted;
    }

    // A numeric email username can start with the same digits as a calling code.
    // Restore those digits when continued typing reveals an email address.
    if (_emailPrefix.isNotEmpty) {
      newValue = newValue.copyWith(
        text: '$_emailPrefix${newValue.text}',
        selection: TextSelection(
          baseOffset: newValue.selection.baseOffset + _emailPrefix.length,
          extentOffset: newValue.selection.extentOffset + _emailPrefix.length,
        ),
      );
      _emailPrefix = '';
    }
    final text = newValue.text.replaceAll(RegExp(r'\s'), '');
    _lastFormattedText = text;
    return TextEditingValue(
      text: text,
      selection: _selectionWithoutWhitespace(newValue.selection, newValue.text),
    );
  }

  bool _isAppending(TextEditingValue oldValue, TextEditingValue newValue) =>
      oldValue.selection.isCollapsed &&
      oldValue.selection.extentOffset == oldValue.text.length &&
      newValue.selection.extentOffset == newValue.text.length &&
      newValue.text.startsWith(oldValue.text) &&
      newValue.text.length == oldValue.text.length + 1;

  (PhoneRegion, int)? _countryPrefix(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    final international = raw.trimLeft().startsWith('+');
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    for (final candidate in PhoneRegion.values) {
      // Bare numbers retain an explicit country choice. A '+' is an explicit
      // request to use the country code in the input instead.
      if (!international && !allowBareCountryInference && candidate != region) {
        continue;
      }
      final code = candidate.code.substring(1);
      if (!digits.startsWith(code)) continue;
      final nationalLength = digits.length - code.length;
      final completeNumber =
          digits.length > candidate.maxDigits &&
          nationalLength >= candidate.minDigits &&
          nationalLength <= candidate.maxDigits;
      final initialUsCode =
          (allowBareCountryInference || region == PhoneRegion.us) &&
          candidate == PhoneRegion.us &&
          oldValue.text.isEmpty &&
          digits.startsWith(code);
      if (!international && !completeNumber && !initialUsCode) continue;

      var digitCount = 0;
      for (var index = 0; index < raw.length; index++) {
        if (RegExp(r'\d').hasMatch(raw[index])) digitCount++;
        if (digitCount == code.length) return (candidate, index + 1);
      }
    }
    return null;
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
