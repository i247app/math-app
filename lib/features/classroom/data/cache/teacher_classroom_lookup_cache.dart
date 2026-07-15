import 'dart:async';

import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/program_models.dart';
import 'package:numi/core/network/school_models.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/school_api.dart';

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
