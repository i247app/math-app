import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Extension on [BuildContext] build context to provide easy access Context Extension.
extension DevicesOsContextExtension on BuildContext {
  // Returns the current [ThemeData] of the [BuildContext].
  ThemeData get _theme => Theme.of(this);

  // Calculates the screen height based on the current [BuildContext] and a given value.
  double screenHeight(double value) => MediaQuery.of(this).size.height * value;

  // Calculates the screen width based on the current [BuildContext] and a given value.
  double screenWidth(double value) => MediaQuery.of(this).size.width * value;

  // Returns the [TextTheme] of the current [BuildContext]'s theme.
  TextTheme get textTheme => _theme.textTheme;

  // Returns the [ColorScheme] of the current [BuildContext]'s theme.
  ColorScheme get colorScheme => _theme.colorScheme;

  // Returns the size of the current [BuildContext]'s device.
  Size get deviceSize => MediaQuery.sizeOf(this);

  // Returns the width of the current [BuildContext]'s device.
  double get deviceWidth => deviceSize.width;
}

extension DateExtension on DateTime {
  String get formattedDate {
    //e.g. 12th Jan 2021 at 12:00 PM
    return '${DateFormat.yMMMd().format(this)} at ${DateFormat.jm().format(this)}';
  }

  String get formattedDateOnly {
    //e.g. Jan 12, 2021
    return DateFormat.yMMMd().format(this);
  }

  String get formattedDateOnlyShort {
    //e.g. Jan 12
    return DateFormat.MMMd().format(this);
  }

  DateTime get dateOnly => DateTime(year, month, day);

  String get formatDynamicDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final updatedDate = DateTime(year, month, day);

    if (today.isAtSameMomentAs(updatedDate)) {
      // If the date is today, return "Today at <time>"
      //e.g. Today, 12:00 PM
      return 'Hôm nay, ${DateFormat.jm().format(this)}';
    } else if (yesterday.isAtSameMomentAs(updatedDate)) {
      // If the date is yesterday, return "Yesterday at <time>"
      //e.g. Yesterday, 12:00 PM
      return 'Hôm qua, ${DateFormat.jm().format(this)}';
    } else {
      if (year == now.year) {
        // If the date is in the current year, return "MMM d at <time>"
        //e.g. Jan 12, 12:00 PM
        return '${DateFormat.MMMd().format(this)}, ${DateFormat.jm().format(this)}';
      } else {
        // Otherwise, return "MMM d, yyyy at <time>"
        //e.g. Jan 12, 2021 at 12:00 PM
        return '${DateFormat.yMMMd().format(this)} at ${DateFormat.jm().format(this)}';
      }
    }
  }
}

extension DoubleFormatting on double {
  String toCurrencySmart({String symbol = '', int defaultDecimal = 3, String? locale}) {
    final isWhole = this == toInt();

    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: isWhole ? 0 : defaultDecimal,
      locale: locale,
    );

    return formatter.format(this);
  }
}

extension StringCurrencyFormatting on String {
  String toCurrencySmartWithString({String symbol = '', int defaultDecimal = 3, String? locale}) {
    String cleanedValue = replaceAll(RegExp(r'[^\d.]'), '');
    final double? valueAsDouble = double.tryParse(cleanedValue);

    if (valueAsDouble == null) {
      return "${symbol}0.00";
    }

    final isWhole = valueAsDouble == valueAsDouble.toInt();

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: isWhole ? 0 : defaultDecimal,
    );

    return formatter.format(valueAsDouble);
  }
}

extension StringFormatting on String {
  double toUnFormattedString() {
    return double.parse(replaceAll(',', ''));
  }
}

extension InputFormattersExtension on String {
  static PhoneNumberFormatter get phoneNumberFormatter => PhoneNumberFormatter();
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');

    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      formatted += text[i];
      if (i == 3 || i == 6) {
        formatted += ' ';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

extension StringFormattingWithCurrency on String {
  String toUnformattedString() {
    // Removes any non-numeric characters, such as commas or spaces
    return replaceAll(RegExp(r'[^0-9.]'), '');
  }

  double toDouble() {
    return double.tryParse(this) ?? 0.0;
  }
}

extension MaskAccountExtension on String {
  String maskAccount([int lastLength = 4]) {
    final cleaned = replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < lastLength) return this;

    final masked =
        '*' * (cleaned.length - lastLength) + cleaned.substring(cleaned.length - lastLength);
    final formatted = masked.replaceAllMapped(RegExp(r".{1,4}"), (match) => "${match.group(0)} ");
    return formatted.trim();
  }
}

extension CurrencyFormatter on num {
  String toCurrencyWithSymbol({String symbol = '₫'}) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '');
    return '${format.format(this)} $symbol';
  }
}

extension CurrencyParser on String {
  double toDoubleFromCurrency() {
    String cleanValue = replaceAll('.', '').replaceAll(',', '');
    return double.tryParse(cleanValue) ?? 0.0;
  }
}

extension SafeFirstWhere<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}

extension MaskedString on String {
  String get masked {
    if (contains('@')) {
      final parts = split('@');
      final username = parts[0];
      final domain = parts[1];

      if (username.length == 1) {
        return '*@$domain';
      } else if (username.length == 2) {
        return '${username[0]}*@$domain';
      } else if (username.length == 3) {
        return '${username[0]}**@$domain';
      } else {
        final first = username[0];
        final last = username.substring(username.length - 2);
        return '$first******$last@$domain';
      }
    } else {
      // Mask phone
      if (length <= 3) return '*' * length;
      final masked = '*' * (length - 3);
      final last = substring(length - 3);
      return '$masked$last';
    }
  }
}

extension StringShortening on String? {
  String short([int maxLength = 6]) {
    if (this == null) {
      return '';
    }
    final currentString = this!;
    if (currentString.length > maxLength) {
      if (maxLength < 0) maxLength = 0;
      if (maxLength > currentString.length) {
        maxLength = currentString.length;
      }
      return '${currentString.substring(0, maxLength)}...';
    } else {
      return currentString;
    }
  }
}

