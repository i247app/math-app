import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  final storage = const FlutterSecureStorage();
  final authTokenStoreKey = 'AUTH_TOKEN';
  final jwtTokenStoreKey = 'JWT_TOKEN';
  final authVerifiedStoreKey = 'AUTH_IS_VERIFIED';
  final _biometricAuthEnabledKey = 'BIOMETRIC_AUTH_ENABLED';
  final _usernameKey = 'USER_NAME';
  final _autoFillUserNameKey = 'AUTO_FILL_USER_NAME';
  final _passwordKey = 'USER_PASSWORD';

  final _rememberMeKey = 'REMEMBER_ME';

  static LocalStorageService? _instance;

  LocalStorageService._internal();

  factory LocalStorageService() {
    _instance ??= LocalStorageService._internal();
    return _instance!;
  }

  Future<String?> getAuthToken() {
    return storage.read(key: authTokenStoreKey);
  }

  Future<void> setAuthToken(String? authToken) {
    return storage.write(key: authTokenStoreKey, value: authToken);
  }

  Future<void> setJwtToken(String? jwtToken) {
    return storage.write(key: jwtTokenStoreKey, value: jwtToken);
  }

  Future<String?> getJwtToken() {
    return storage.read(key: jwtTokenStoreKey);
  }

  Future<String?> getAuthVerified() {
    return storage.read(key: authVerifiedStoreKey);
  }

  Future<void> setAuthVerified(String? authVerified) {
    return storage.write(key: authVerifiedStoreKey, value: authVerified);
  }

  Future<void> setUserCredentials(String username, String password) async {
    await storage.write(key: _usernameKey, value: username);
    await storage.write(key: _passwordKey, value: password);
  }

  Future<void> removeUserCredentials() async {
    await storage.delete(key: _usernameKey);
    await storage.delete(key: _passwordKey);
    debugPrint("User credentials have been removed from local storage.");
  }

  Future<String?> getUserName() {
    return storage.read(key: _usernameKey);
  }

  Future<String?> getPassword() {
    return storage.read(key: _passwordKey);
  }

  Future<bool> isBiometricAuthEnabled() async {
    final isEnabled = await storage.read(key: _biometricAuthEnabledKey);
    return isEnabled == 'true';
  }

  Future<void> setBiometricAuthEnabled(bool isEnabled) async {
    await storage.write(key: _biometricAuthEnabledKey, value: isEnabled.toString());
  }

  Future<void> setRememberMe(bool remember) async {
    await storage.write(key: _rememberMeKey, value: remember.toString());
  }

  Future<bool> getRememberMe() async {
    final v = await storage.read(key: _rememberMeKey);
    return v == 'true';
  }

  Future<void> setAutoFillUserName(String? username) async {
    await storage.write(key: _autoFillUserNameKey, value: username);
  }

  Future<String?> getAutoFillUserName() {
    return storage.read(key: _autoFillUserNameKey);
  }

  Future<void> clearAll() async {
    await storage.deleteAll();
    debugPrint("All local storage cleared.");
  }
}
