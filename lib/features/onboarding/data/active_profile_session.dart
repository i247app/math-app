import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/profile_models.dart';

enum ProfileRole {
  student,
  parent,
  teacher;

  static ProfileRole fromProfile(StudentProfile? profile) {
    final role = profile?.role?.trim().toUpperCase();
    return switch (role) {
      'PARENT' => ProfileRole.parent,
      'TEACHER' => ProfileRole.teacher,
      _ => ProfileRole.student,
    };
  }
}

class ActiveProfileResolution {
  const ActiveProfileResolution({
    required this.profiles,
    required this.activeProfile,
  });

  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;

  ProfileRole get role => ProfileRole.fromProfile(activeProfile);

  String? get activeProfileId =>
      ActiveProfileSession.profileStableId(activeProfile);
}

class ActiveProfileSession {
  const ActiveProfileSession({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  Future<String?> readActiveProfileId(String userId) async {
    final key = _storageKey(userId);
    if (key == null) {
      return null;
    }
    return (await _storage.read(key: key))?.trim();
  }

  Future<void> writeActiveProfileId({
    required String userId,
    required String profileId,
  }) async {
    final key = _storageKey(userId);
    final normalizedProfileId = profileId.trim();
    if (key == null || normalizedProfileId.isEmpty) {
      return;
    }
    await _storage.write(key: key, value: normalizedProfileId);
  }

  Future<void> clearActiveProfileId(String userId) async {
    final key = _storageKey(userId);
    if (key == null) {
      return;
    }
    await _storage.delete(key: key);
  }

  Future<StudentProfile?> resolveActiveProfile({
    required String userId,
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
    String? storedProfileId,
  }) {
    if (profiles.isEmpty) {
      return null;
    }

    final normalizedStoredId = storedProfileId?.trim();
    if (normalizedStoredId != null && normalizedStoredId.isNotEmpty) {
      for (final profile in profiles) {
        if (profileStableId(profile) == normalizedStoredId) {
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

  static String? profileStableId(StudentProfile? profile) {
    final profileId = profile?.profileId?.trim();
    if (profileId != null && profileId.isNotEmpty) {
      return profileId;
    }

    final id = profile?.id?.trim();
    if (id != null && id.isNotEmpty) {
      return id;
    }

    return null;
  }

  static String? _storageKey(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return null;
    }
    return 'active_profile_id:$normalizedUserId';
  }
}
