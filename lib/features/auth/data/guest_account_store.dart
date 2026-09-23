import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:numi/features/auth/models/guest_account.dart';

class GuestAccountStore {
  const GuestAccountStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const guestUidKey = 'guest_uid';

  /// Legacy key: guest user objects now live only in GuestAccountApi memory.
  static const guestUserKey = 'guest_user';

  final FlutterSecureStorage _storage;

  Future<int?> readUid() async {
    final storedUid = GuestAccount.positiveInt(
      await _storage.read(key: guestUidKey),
    );
    if (storedUid != null) {
      await _storage.delete(key: guestUserKey);
      return storedUid;
    }

    final raw = await _storage.read(key: guestUserKey);
    if (raw == null || raw.isEmpty) return null;
    int? legacyUid;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        legacyUid =
            GuestAccount.positiveInt(decoded['uid']) ??
            GuestAccount.positiveInt(decoded['id']);
      }
    } on FormatException {
      // An invalid legacy object cannot be migrated.
    }
    if (legacyUid != null) {
      await _storage.write(key: guestUidKey, value: legacyUid.toString());
    }
    await _storage.delete(key: guestUserKey);
    return legacyUid;
  }

  Future<void> writeUid(int uid) async {
    await _storage.write(key: guestUidKey, value: uid.toString());
    await _storage.delete(key: guestUserKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: guestUidKey);
    await _storage.delete(key: guestUserKey);
  }
}
