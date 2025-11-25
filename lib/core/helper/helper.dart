import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../config/overlay_style_config.dart';

String locale = 'vi_VN';

class Helper {
  Helper._();

  static void overlayNavigation(BuildContext context) {
    OverlayStyleConfig.overlayNavigation(context);
  }

  static overlayStyleAppBar(BuildContext context) {
    return OverlayStyleConfig.overlayAppBar(context);
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static String getAssetImage(String name) {
    return 'assets/images/$name';
  }

  static String getAssetSvg(String name) {
    return 'assets/svgs/$name';
  }

  static String generateUUID() {
    return const Uuid().v4();
  }

  static String formatCurrency(double amount) {
    final format = NumberFormat.decimalPattern(locale);
    return format.format(amount);
  }

  // static int? getCountryIdByName(String? countryName, List<Country> countries) {
  //   if (countryName == null) return null;
  //   final country = countries.firstWhere(
  //     (c) => c.name == countryName,
  //     orElse: () => Country(id: -1, name: countryName),
  //   );
  //   return country.id;
  // }

  // static int? getBankIdByName(
  //   String? bankName,
  //   List<BankAccountByCountry> banks,
  // ) {
  //   if (bankName == null) return null;
  //   final bank = banks.firstWhere(
  //     (b) => b.name == bankName,
  //     orElse: () => BankAccountByCountry(bankId: -1, name: bankName),
  //   );
  //   return bank.bankId;
  // }

  static String removeVietnameseDiacritics(String str) {
    str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    str = str.replaceAll(RegExp(r'đ'), 'd');
    str = str.replaceAll(RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'), 'A');
    str = str.replaceAll(RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'), 'E');
    str = str.replaceAll(RegExp(r'[ÌÍỊỈĨ]'), 'I');
    str = str.replaceAll(RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'), 'O');
    str = str.replaceAll(RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'), 'U');
    str = str.replaceAll(RegExp(r'[ỲÝỴỶỸ]'), 'Y');
    str = str.replaceAll(RegExp(r'Đ'), 'D');

    return str;
  }

  // static String getCodeByCurrencyCoreId(int? id) {
  //   if (id == Currency.vnd.coreId) {
  //     return Currency.vnd.code;
  //   }
  //   return Currency.usd.code;
  // }

  // static int getCoreIdByCurrencyCode(String? code) {
  //   if (code == Currency.vnd.code) {
  //     return Currency.vnd.coreId;
  //   }
  //   return Currency.usd.coreId;
  // }

  // static String getReceiveCurrencyCode(String? code) {
  //   if (code == Currency.vnd.code) {
  //     return Currency.vnd.code;
  //   }
  //   return Currency.usd.code;
  // }

  // static String getCountryCodeByCurrencyCode(String? code) {
  //   if (code == Currency.vnd.code) {
  //     return Currency.vnd.countryCode;
  //   }
  //   return Currency.usd.countryCode;
  // }

  static bool? jsonIntToBool(int? value) {
    if (value != null) {
      if (value == 1) {
        return true;
      } else if (value == 0) {
        return false;
      }
    }

    return null;
  }
}
