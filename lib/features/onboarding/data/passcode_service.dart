import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasscodeException implements Exception {
  const PasscodeException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class PasscodeService {
  Future<bool> hasPasscode(int userId);

  Future<void> setPasscode({
    required int userId,
    required String passcode,
  });

  Future<bool> verifyPasscode({
    required int userId,
    required String passcode,
  });

  Future<void> clearPasscode(int userId);
}

class SecurePasscodeService implements PasscodeService {
  const SecurePasscodeService({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _keyPrefix = 'local_passcode_v1_user_';

  final FlutterSecureStorage _storage;

  @override
  Future<bool> hasPasscode(int userId) async {
    if (userId <= 0) {
      return false;
    }

    final passcode = await _readPasscode(userId);
    return passcode != null;
  }

  @override
  Future<void> setPasscode({
    required int userId,
    required String passcode,
  }) async {
    _validateInput(userId: userId, passcode: passcode);
    await _storage.write(
      key: _storageKey(userId),
      value: passcode,
    );
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
  }

  Future<String?> _readPasscode(int userId) async {
    final value = await _storage.read(key: _storageKey(userId));
    final passcode = value?.trim();
    if (passcode == null || !RegExp(r'^\d{4}$').hasMatch(passcode)) {
      return null;
    }
    return passcode;
  }

  static void _validateInput({
    required int userId,
    required String passcode,
  }) {
    if (userId <= 0) {
      throw const PasscodeException('Missing user id.');
    }
    if (!RegExp(r'^\d{4}$').hasMatch(passcode)) {
      throw const PasscodeException('Passcode must contain 4 digits.');
    }
  }

  static String _storageKey(int userId) => '$_keyPrefix$userId';
}
