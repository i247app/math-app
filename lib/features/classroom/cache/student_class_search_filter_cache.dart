import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/core/network/school_models.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/profile/school_api.dart';

class StudentClassSearchFilterOptions {
  const StudentClassSearchFilterOptions({
    required this.userId,
    required this.grades,
    required this.schools,
  });

  final int userId;
  final List<GradeModel> grades;
  final List<SchoolModel> schools;
}

class StudentClassSearchFilterCache {
  StudentClassSearchFilterCache._();

  static final shared = StudentClassSearchFilterCache._();

  final Map<int, StudentClassSearchFilterOptions> _cache =
      <int, StudentClassSearchFilterOptions>{};
  final Map<int, Future<StudentClassSearchFilterOptions>> _pending =
      <int, Future<StudentClassSearchFilterOptions>>{};

  StudentClassSearchFilterOptions? get(int userId) => _cache[userId];

  Future<StudentClassSearchFilterOptions> load({
    required int userId,
    required GradeService gradeService,
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
      schoolService: schoolService,
    );
    _pending[userId] = request;
    return request.whenComplete(() {
      if (identical(_pending[userId], request)) {
        _pending.remove(userId);
      }
    });
  }

  Future<StudentClassSearchFilterOptions> _loadFresh({
    required int userId,
    required GradeService gradeService,
    required SchoolService schoolService,
  }) async {
    final results = await Future.wait<Object>([
      gradeService.listGrades(userId: userId),
      schoolService.listSchools(),
    ]);
    final options = StudentClassSearchFilterOptions(
      userId: userId,
      grades: List.unmodifiable(results[0] as List<GradeModel>),
      schools: List.unmodifiable(results[1] as List<SchoolModel>),
    );
    _cache[userId] = options;
    return options;
  }

  void invalidate(int userId) {
    _cache.remove(userId);
    _pending.remove(userId);
  }
}
