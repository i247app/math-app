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
