import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileGradeProgress {
  const ProfileGradeProgress({
    required this.grade,
    required this.level,
    this.highestUnlockedGrade,
    this.highestUnlockedLevel,
  });

  static const initial = ProfileGradeProgress(grade: 0, level: 0);

  final int grade;
  final int level;
  final int? highestUnlockedGrade;
  final int? highestUnlockedLevel;

  int get sortValue => (grade * 10) + level;
  int get highestUnlockedSortValue =>
      ((highestUnlockedGrade ?? grade) * 10) + (highestUnlockedLevel ?? level);

  bool isHigherThan(ProfileGradeProgress other) {
    return sortValue > other.sortValue;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'grade': grade,
    'level': level,
    'highest_unlocked_grade': highestUnlockedGrade ?? grade,
    'highest_unlocked_level': highestUnlockedLevel ?? level,
  };

  static ProfileGradeProgress? fromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final grade = _asInt(value['grade']);
    final level = _asInt(value['level']);
    if (grade == null || level == null) {
      return null;
    }
    return ProfileGradeProgress(
      grade: grade.clamp(0, 5),
      level: level.clamp(0, 10),
      highestUnlockedGrade: (_asInt(value['highest_unlocked_grade']) ?? grade)
          .clamp(0, 5),
      highestUnlockedLevel: (_asInt(value['highest_unlocked_level']) ?? level)
          .clamp(0, 10),
    );
  }

  ProfileGradeProgress preserveHighest(ProfileGradeProgress previous) {
    if (highestUnlockedSortValue >= previous.highestUnlockedSortValue) {
      return this;
    }
    return ProfileGradeProgress(
      grade: grade,
      level: level,
      highestUnlockedGrade: previous.highestUnlockedGrade ?? previous.grade,
      highestUnlockedLevel: previous.highestUnlockedLevel ?? previous.level,
    );
  }
}

abstract interface class ProfileGradeProgressStore {
  Future<ProfileGradeProgress> read(int profileId);

  Future<void> save(int profileId, ProfileGradeProgress progress);

  Future<ProfileGradeProgress> saveIfHigher(
    int profileId,
    ProfileGradeProgress progress,
  );
}

class SecureProfileGradeProgressStore implements ProfileGradeProgressStore {
  const SecureProfileGradeProgressStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _storageKey = 'profile_grade_progress_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<ProfileGradeProgress> read(int profileId) async {
    if (profileId <= 0) {
      return ProfileGradeProgress.initial;
    }
    final allProgress = await _readAll();
    return ProfileGradeProgress.fromJson(allProgress['$profileId']) ??
        ProfileGradeProgress.initial;
  }

  @override
  Future<void> save(int profileId, ProfileGradeProgress progress) async {
    if (profileId <= 0) {
      return;
    }
    final allProgress = await _readAll();
    final previous =
        ProfileGradeProgress.fromJson(allProgress['$profileId']) ??
        ProfileGradeProgress.initial;
    allProgress['$profileId'] = progress.preserveHighest(previous).toJson();
    await _storage.write(key: _storageKey, value: jsonEncode(allProgress));
  }

  @override
  Future<ProfileGradeProgress> saveIfHigher(
    int profileId,
    ProfileGradeProgress progress,
  ) async {
    if (profileId <= 0) {
      return progress;
    }
    final allProgress = await _readAll();
    final current =
        ProfileGradeProgress.fromJson(allProgress['$profileId']) ??
        ProfileGradeProgress.initial;
    if (!progress.isHigherThan(current)) {
      return current;
    }
    allProgress['$profileId'] = progress.toJson();
    await _storage.write(key: _storageKey, value: jsonEncode(allProgress));
    return progress;
  }

  Future<Map<String, dynamic>> _readAll() async {
    final encoded = await _storage.read(key: _storageKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(encoded);
      return decoded is Map<String, dynamic>
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }
}

int? _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
