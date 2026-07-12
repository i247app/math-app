import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasscodeException implements Exception {
  const PasscodeException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PasscodeLoginAccount {
  const PasscodeLoginAccount({required this.userId, required this.phone});

  final int userId;
  final String phone;
}

abstract class PasscodeService {
  Future<int?> lastPasscodeUserId();
  Future<PasscodeLoginAccount?> lastPasscodeAccount();
  Future<bool> hasPasscode(int userId);
  Future<void> rememberLoginAccount({
    required int userId,
    required String phone,
  });
  Future<void> setPasscode({required int userId, required String passcode});
  Future<bool> verifyPasscode({required int userId, required String passcode});
  Future<void> clearPasscode(int userId);
}

class SecurePasscodeService implements PasscodeService {
  const SecurePasscodeService({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _keyPrefix = 'local_passcode_v1_user_';
  static const _phoneKeyPrefix = 'local_passcode_v1_phone_user_';
  static const _lastUserIdKey = 'local_passcode_v1_last_user_id';

  final FlutterSecureStorage _storage;

  @override
  Future<int?> lastPasscodeUserId() async {
    final value = await _storage.read(key: _lastUserIdKey);
    final userId = int.tryParse(value?.trim() ?? '');
    if (userId != null && userId > 0 && await hasPasscode(userId)) {
      return userId;
    }
    if (userId != null) {
      await _storage.delete(key: _lastUserIdKey);
    }
    return _findExistingPasscodeUserId();
  }

  @override
  Future<PasscodeLoginAccount?> lastPasscodeAccount() async {
    final value = await _storage.read(key: _lastUserIdKey);
    final userId = int.tryParse(value?.trim() ?? '');
    if (userId == null || userId <= 0 || !await hasPasscode(userId)) {
      return null;
    }
    final phone = (await _storage.read(key: _phoneStorageKey(userId)))?.trim();
    if (phone == null || phone.isEmpty) {
      return null;
    }
    return PasscodeLoginAccount(userId: userId, phone: phone);
  }

  @override
  Future<bool> hasPasscode(int userId) async {
    if (userId <= 0) {
      return false;
    }
    return await _readPasscode(userId) != null;
  }

  @override
  Future<void> rememberLoginAccount({
    required int userId,
    required String phone,
  }) async {
    final normalizedPhone = phone.trim();
    if (userId <= 0 || normalizedPhone.isEmpty) {
      throw const PasscodeException('Missing login account information.');
    }
    await _storage.write(key: _phoneStorageKey(userId), value: normalizedPhone);
    await _storage.write(key: _lastUserIdKey, value: '$userId');
  }

  @override
  Future<void> setPasscode({
    required int userId,
    required String passcode,
  }) async {
    _validateInput(userId: userId, passcode: passcode);
    await _storage.write(key: _storageKey(userId), value: passcode);
    await _storage.write(key: _lastUserIdKey, value: '$userId');
  }

  @override
  Future<bool> verifyPasscode({
    required int userId,
    required String passcode,
  }) async {
    if (userId <= 0 || passcode.length != 4) {
      return false;
    }
    final stored = await _readPasscode(userId);
    return stored == passcode;
  }

  @override
  Future<void> clearPasscode(int userId) async {
    if (userId <= 0) {
      return;
    }
    await _storage.delete(key: _storageKey(userId));
    final lastUserId = await lastPasscodeUserId();
    if (lastUserId == userId) {
      await _storage.delete(key: _lastUserIdKey);
    }
  }

  Future<String?> _readPasscode(int userId) async {
    final passcode = (await _storage.read(key: _storageKey(userId)))?.trim();
    return passcode != null && RegExp(r'^\d{4}$').hasMatch(passcode)
        ? passcode
        : null;
  }

  Future<int?> _findExistingPasscodeUserId() async {
    final values = await _storage.readAll();
    for (final entry in values.entries) {
      if (!entry.key.startsWith(_keyPrefix) ||
          !RegExp(r'^\d{4}$').hasMatch(entry.value.trim())) {
        continue;
      }
      final userId = int.tryParse(entry.key.substring(_keyPrefix.length));
      if (userId == null || userId <= 0) {
        continue;
      }
      await _storage.write(key: _lastUserIdKey, value: '$userId');
      return userId;
    }
    return null;
  }

  static void _validateInput({required int userId, required String passcode}) {
    if (userId <= 0) {
      throw const PasscodeException('Missing user id.');
    }
    if (!RegExp(r'^\d{4}$').hasMatch(passcode)) {
      throw const PasscodeException('Passcode must contain 4 digits.');
    }
  }

  static String _storageKey(int userId) => '$_keyPrefix$userId';
  static String _phoneStorageKey(int userId) => '$_phoneKeyPrefix$userId';
}
