import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class CurrencyUtils {
  static String? parseCurrencyToPlainAmount(String formattedString) {
    String cleanedString = formattedString.trim();

    final List<NumberFormat> formatsToTry = [
      NumberFormat.currency(locale: 'en_US'),

      NumberFormat.currency(locale: 'vi_VN'),

      NumberFormat.currency(locale: 'en_US', name: 'USD'),

      NumberFormat.currency(locale: 'vi_VN', name: 'VND'),
    ];

    for (var format in formatsToTry) {
      try {
        num parsedValue = format.parse(cleanedString);

        return parsedValue.toString();
      } catch (e) {
        debugPrint("Parsing failed for format ${format.locale}: $e");
      }
    }
    return null;
  }
}
