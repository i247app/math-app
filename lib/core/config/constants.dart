import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Constants {
  static const List<String> offerImages = [
    "images/offers/crab1.jpg",
    "images/offers/crab2.jpg",
    "images/offers/crab3.png",
    "images/offers/crab5.png",
    "images/offers/crab6.png",
  ];
  static const List<String> authImagesPaths = [
    "images/landing/login_background_1.png",
    "images/landing/sign_up.png",
  ];
  static const List<Color> kDefaultRainbowColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];
  static const String symbol = "₫";
  static const double defaultPadding = 10.0;

  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  static String getCurrentDayFormatted() => formatDate(DateTime.now());

  
  static double? parseAndRound(String input) {
    try {
      input = input.replaceAll(',', '.');
      double? value = double.tryParse(input);
      return value != null ? double.parse(value.toStringAsFixed(3)) : null;
    } catch (e) {
      return null;
    }
  }
  static String formatCurrency(dynamic amount, [String? symbol]) {
    if (amount != null) {
      final formatter = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: symbol ?? '',
      );
      return formatter.format(amount).replaceAll('.', ' ');
    }
    return "Unknown";
  }

  static String unformatCurrency(dynamic amount) {
    return amount.toString().replaceAll(RegExp(r'\D'), '');
  }

  static String formatNumber(dynamic amount) {
    double value = double.parse(amount.toString());
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 10) return "";
    return phoneNumber.replaceAllMapped(
      RegExp(r"(\d{4})(\d{3})(\d{3})"),
      (match) => "${match[1]} ${match[2]} ${match[3]}",
    );
  }

  static String removeTrailingZeros(double number) {
    return number.toString().replaceAll(RegExp(r"([.]*0+)$"), "");
  }

  static Map<String, String> convertStringToDateAndTime(String input) {
    
    DateFormat inputFormat = DateFormat("yyyy-MM-dd HH:mm");
    DateTime dateTime = inputFormat.parse(input);
    
    String date = DateFormat("dd/MM/yyyy").format(dateTime);
    String time = DateFormat("HH:mm").format(dateTime);
    return {"date": date, "time": time};
  }

  static String trimDateTime(String input) {
    if (input.length >= 16) {
      return input.substring(0, 16);
    }
    return input;
  }
}
