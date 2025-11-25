import 'package:flutter/material.dart';

import '../../core/localization/app_string.dart';

enum LingoLocale { us, vn }

class LingoProvider with ChangeNotifier {
  LingoLocale _locale;
  Map<String, String> _translations = {};
  bool _isInitialized = false;

  LingoProvider({required LingoLocale locale}) : _locale = locale;

  LingoLocale get locale => _locale;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    await _loadTranslations();
    _isInitialized = true;
    notifyListeners();
  }

  String lookup(String key) {
    return _translations[key] ?? key;
  }

  void setLocale(LingoLocale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      _loadTranslations().then((_) => notifyListeners());
    }
  }

  Future<void> _loadTranslations() async {
    _translations = AppStrings.getAll(_locale == LingoLocale.vn ? 'vi' : 'en');
  }
}
