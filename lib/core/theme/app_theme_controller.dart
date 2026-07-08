import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    PlatformDispatcher? platformDispatcher,
  }) : _storage = storage,
       _platformDispatcher = platformDispatcher ?? PlatformDispatcher.instance;

  static const _storageKey = 'app_theme_mode';
  static const _darkValue = 'dark';
  static const _lightValue = 'light';
  static const _systemValue = 'system';

  final FlutterSecureStorage _storage;
  final PlatformDispatcher _platformDispatcher;

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;

  bool get isInitialized => _isInitialized;

  bool get isDarkMode {
    return switch (_themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        _platformDispatcher.platformBrightness == Brightness.dark,
    };
  }

  Future<void> initialize() async {
    final savedValue = await _storage.read(key: _storageKey);
    _themeMode = _themeModeFromStorageValue(savedValue);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode && _isInitialized) {
      return;
    }
    _themeMode = mode;
    await _storage.write(key: _storageKey, value: _storageValueFor(mode));
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) {
    return setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  static ThemeMode _themeModeFromStorageValue(String? value) {
    return switch (value?.trim().toLowerCase()) {
      _darkValue => ThemeMode.dark,
      _lightValue => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  static String _storageValueFor(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => _darkValue,
      ThemeMode.light => _lightValue,
      ThemeMode.system => _systemValue,
    };
  }
}
