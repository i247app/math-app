import 'dart:async';

import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/profile/domain/models/program.dart';
import 'package:numi/features/profile/domain/models/school.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/profile/application/contracts/school_service.dart';

class TeacherClassroomLookupOptions {
  const TeacherClassroomLookupOptions({
    required this.userId,
    required this.grades,
    required this.programs,
    required this.schools,
  });

  final int userId;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final List<SchoolModel> schools;
}

class TeacherClassroomLookupCache {
  TeacherClassroomLookupCache._();

  static final shared = TeacherClassroomLookupCache._();

  final Map<int, TeacherClassroomLookupOptions> _cache =
      <int, TeacherClassroomLookupOptions>{};
  final Map<int, Future<TeacherClassroomLookupOptions>> _pending =
      <int, Future<TeacherClassroomLookupOptions>>{};

  TeacherClassroomLookupOptions? get(int userId) {
    return _cache[userId];
  }

  Future<TeacherClassroomLookupOptions> load({
    required int userId,
    required GradeService gradeService,
    required ProfileService profileService,
    required SchoolService schoolService,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = _cache[userId];
      if (cached != null) {
        return Future.value(cached);
      }
      final pending = _pending[userId];
      if (pending != null) {
        return pending;
      }
    }

    final request = _loadFresh(
      userId: userId,
      gradeService: gradeService,
      profileService: profileService,
      schoolService: schoolService,
    );
    _pending[userId] = request;
    return request.whenComplete(() {
      if (identical(_pending[userId], request)) {
        _pending.remove(userId);
      }
    });
  }

  Future<TeacherClassroomLookupOptions> _loadFresh({
    required int userId,
    required GradeService gradeService,
    required ProfileService profileService,
    required SchoolService schoolService,
  }) async {
    final results = await Future.wait<Object>([
      gradeService.listGrades(userId: userId),
      profileService.listPrograms(userId: userId),
      schoolService.listSchools(),
    ]);
    final options = TeacherClassroomLookupOptions(
      userId: userId,
      grades: List.unmodifiable(results[0] as List<GradeModel>),
      programs: List.unmodifiable(results[1] as List<ProgramModel>),
      schools: List.unmodifiable(results[2] as List<SchoolModel>),
    );
    _cache[userId] = options;
    return options;
  }

  void invalidate(int userId) {
    _cache.remove(userId);
    _pending.remove(userId);
  }

  void clear() {
    _cache.clear();
    _pending.clear();
  }
}
