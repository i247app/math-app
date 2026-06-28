part of '../presentation/teacher_classroom_screens.dart';

class _TeacherClassroomLookupOptions {
  const _TeacherClassroomLookupOptions({
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

class _TeacherClassroomLookupCache {
  _TeacherClassroomLookupCache._();

  static final shared = _TeacherClassroomLookupCache._();

  final Map<int, _TeacherClassroomLookupOptions> _cache =
      <int, _TeacherClassroomLookupOptions>{};
  final Map<int, Future<_TeacherClassroomLookupOptions>> _pending =
      <int, Future<_TeacherClassroomLookupOptions>>{};

  _TeacherClassroomLookupOptions? get(int userId) {
    return _cache[userId];
  }

  Future<_TeacherClassroomLookupOptions> load({
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

  Future<_TeacherClassroomLookupOptions> _loadFresh({
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
    final options = _TeacherClassroomLookupOptions(
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
