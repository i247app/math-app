import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/core/network/program_models.dart';
import 'package:numi_flutter/core/network/school_models.dart';
import 'package:numi_flutter/core/network/semester_models.dart';

const settingsProfileOptionsCacheTtl = Duration(minutes: 10);

class SettingsProfileOptionsSnapshot {
  const SettingsProfileOptionsSnapshot({
    required this.userId,
    required this.schools,
    required this.grades,
    required this.programs,
    required this.semesters,
    required this.createdAt,
  });

  final int userId;
  final List<SchoolModel> schools;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final List<SemesterModel> semesters;
  final DateTime createdAt;

  bool get isFresh {
    return DateTime.now().difference(createdAt) <
        settingsProfileOptionsCacheTtl;
  }
}

class SettingsProfileOptionsCache {
  SettingsProfileOptionsCache._();

  static final SettingsProfileOptionsCache instance =
      SettingsProfileOptionsCache._();

  SettingsProfileOptionsSnapshot? _snapshot;

  SettingsProfileOptionsSnapshot? readFresh({required int userId}) {
    final snapshot = _snapshot;
    if (snapshot == null || snapshot.userId != userId || !snapshot.isFresh) {
      return null;
    }
    return snapshot;
  }

  void save({
    required int userId,
    required List<SchoolModel> schools,
    required List<GradeModel> grades,
    required List<ProgramModel> programs,
    required List<SemesterModel> semesters,
  }) {
    _snapshot = SettingsProfileOptionsSnapshot(
      userId: userId,
      schools: List<SchoolModel>.unmodifiable(schools),
      grades: List<GradeModel>.unmodifiable(grades),
      programs: List<ProgramModel>.unmodifiable(programs),
      semesters: List<SemesterModel>.unmodifiable(semesters),
      createdAt: DateTime.now(),
    );
  }

  void clear() {
    _snapshot = null;
  }
}
