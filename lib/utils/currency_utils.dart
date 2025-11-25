

import 'package:intl/intl.dart';

class CurrencyUtils {
  static String? parseCurrencyToPlainAmount(String formattedString) {
    String cleanedString = formattedString.trim();

    // List of NumberFormat instances to try.
    // Order can matter if a string could ambiguously match multiple formats,
    // though less likely with distinct currency symbols/codes.
    final List<NumberFormat> formatsToTry = [
      // Standard USD format (e.g., "$1,234.56")
      NumberFormat.currency(locale: 'en_US'),

      // Standard VND format (e.g., "1.234.567 ₫" or "1.234.567,89 ₫")
      // For vi_VN, '.' is typically a group separator and ',' is a decimal separator.
      // The currency symbol is '₫'.
      NumberFormat.currency(locale: 'vi_VN'),

      // Formats with currency codes instead of symbols
      // e.g., "USD 1,234.56" or "1,234.56 USD" (NumberFormat handles placement)
      NumberFormat.currency(locale: 'en_US', name: 'USD'),
      // e.g., "VND 1.234.567" or "1.234.567 VND"
      NumberFormat.currency(locale: 'vi_VN', name: 'VND'),
    ];

    for (var format in formatsToTry) {
      try {
        num parsedValue = format.parse(cleanedString);
        // .toString() will give "1234" for integers, "1234.56" for doubles.
        // This fits the "plain amount string" requirement.
        return parsedValue.toString();
      } catch (e) {
        // Parsing with this format failed, try the next one.
        // You can log the error for debugging if needed:
        // debugPrint('Debug: Failed to parse "$cleanedString" with format for locale ${format.locale}, symbol ${format.currencySymbol}, name ${format.currencyName}. Error: $e');
      }
    }
    return null;
  }
}
