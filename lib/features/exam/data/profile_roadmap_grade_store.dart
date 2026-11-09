import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:numi/features/exam/data/profile_grade_progress_store.dart';

/// Remembers the viewed grade independently of exam progress and unlocked levels.
class ProfileRoadmapGradeStore {
  const ProfileRoadmapGradeStore({
    this._storage = const FlutterSecureStorage(),
  });

  final FlutterSecureStorage _storage;

  Future<int?> read(int profileId) async {
    if (profileId <= 0) return null;
    try {
      final selected = int.tryParse(
        await _storage.read(key: 'profile_roadmap_grade_$profileId') ?? '',
      );
      if (selected != null && selected >= 0 && selected <= 5) return selected;

      // Existing users with saved progress can keep opening their roadmap.
      final encoded = await _storage.read(key: 'profile_grade_progress_v1');
      if (encoded == null) return null;
      final progress = jsonDecode(encoded);
      return progress is Map
          ? ProfileGradeProgress.fromJson(progress['$profileId'])?.grade
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(int profileId, int grade) async {
    if (profileId <= 0 || grade < 0 || grade > 5) return;
    try {
      await _storage.write(
        key: 'profile_roadmap_grade_$profileId',
        value: '$grade',
      );
    } catch (_) {
      // A temporary storage failure must not prevent opening the roadmap.
    }
  }
}
