import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/features/profile/models/semester.dart';

const profileOptionsCacheTtl = Duration(minutes: 10);

class ProfileOptionsSnapshot {
  const ProfileOptionsSnapshot({
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
    return DateTime.now().difference(createdAt) < profileOptionsCacheTtl;
  }
}

class ProfileOptionsCache {
  ProfileOptionsCache._();

  static final ProfileOptionsCache instance = ProfileOptionsCache._();

  ProfileOptionsSnapshot? _snapshot;

  ProfileOptionsSnapshot? readFresh({required int userId}) {
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
    _snapshot = ProfileOptionsSnapshot(
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
