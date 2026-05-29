import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_language.dart';
import 'app_strings.dart';

class LingoProvider extends ChangeNotifier {
  LingoProvider({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    Locale? deviceLocale,
  })  : _storage = storage,
        _deviceLocale = deviceLocale;

  static const _storageKey = 'app_language';

  final FlutterSecureStorage _storage;
  final Locale? _deviceLocale;

  AppLanguage _language = AppLanguage.vi;
  Map<String, String> _translations = AppStrings.getAll(AppLanguage.vi);
  bool _isInitialized = false;

  AppLanguage get language => _language;

  bool get isInitialized => _isInitialized;

  String get languageCode => _language.apiCode;

  Future<void> initialize() async {
    final savedCode = await _storage.read(key: _storageKey);
    final resolved = savedCode == null || savedCode.trim().isEmpty
        ? AppLanguage.fromDevice(
            _deviceLocale ?? PlatformDispatcher.instance.locale)
        : AppLanguage.fromCode(savedCode);
    _setLanguage(resolved);
    _isInitialized = true;
    notifyListeners();
  }

  String lookup(String key) {
    return _translations[key] ?? key;
  }

  String format(String key, Map<String, Object?> values) {
    var text = lookup(key);
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value?.toString() ?? '');
    }
    return text;
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language && _isInitialized) {
      return;
    }
    _setLanguage(language);
    await _storage.write(key: _storageKey, value: language.apiCode);
    notifyListeners();
  }

  void _setLanguage(AppLanguage language) {
    _language = language;
    AppLanguageState.current = language;
    _translations = AppStrings.getAll(language);
  }
}
