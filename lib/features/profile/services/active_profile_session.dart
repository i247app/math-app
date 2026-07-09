import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:numi/core/network/profile_models.dart';

class ActiveProfileSession {
  const ActiveProfileSession({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  Future<int?> readActiveProfileId(int userId) async {
    final key = _storageKey(userId);
    if (key == null) {
      return null;
    }
    return _decodeStoredProfileId(await _storage.read(key: key));
  }

  Future<void> writeActiveProfileId({
    required int userId,
    required int profileId,
  }) async {
    final key = _storageKey(userId);
    if (key == null) {
      return;
    }
    await _storage.write(key: key, value: _encodeStoredProfileId(profileId));
  }

  Future<void> clearActiveProfileId(int userId) async {
    final key = _storageKey(userId);
    if (key == null) {
      return;
    }
    await _storage.delete(key: key);
  }

  Future<StudentProfile?> resolveActiveProfile({
    required int userId,
    required List<StudentProfile> profiles,
  }) async {
    final storedProfileId = await readActiveProfileId(userId);
    return resolveActiveProfileFromProfiles(
      profiles: profiles,
      storedProfileId: storedProfileId,
    );
  }

  static StudentProfile? resolveActiveProfileFromProfiles({
    required List<StudentProfile> profiles,
    int? storedProfileId,
  }) {
    if (profiles.isEmpty) {
      return null;
    }

    if (storedProfileId != null) {
      for (final profile in profiles) {
        if (profileStableId(profile) == storedProfileId) {
          return profile;
        }
      }
    }

    for (final profile in profiles) {
      if (profile.isDefault) {
        return profile;
      }
    }

    return profiles.first;
  }

  static int? profileStableId(StudentProfile? profile) {
    return profile?.profileId ?? profile?.id;
  }

  static String? _storageKey(int userId) {
    if (userId <= 0) {
      return null;
    }
    return 'active_profile_id:${_encodeStoredUserId(userId)}';
  }

  static String _encodeStoredUserId(int userId) => '$userId';

  static String _encodeStoredProfileId(int profileId) => '$profileId';

  static int? _decodeStoredProfileId(String? value) {
    final stored = value?.trim();
    return stored == null || stored.isEmpty ? null : int.tryParse(stored);
  }
}
