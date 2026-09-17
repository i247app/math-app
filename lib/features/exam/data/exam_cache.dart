import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_service.dart';

typedef ExamDetailLoader = Future<GeneratedExam> Function(int detailId);

class ExamCache {
  ExamCache._();

  static const _emptyDetailRetryDelay = Duration(milliseconds: 450);

  static final Map<_ExamListKey, List<GeneratedExam>> _lists =
      <_ExamListKey, List<GeneratedExam>>{};
  static final Map<_ExamListKey, DateTime> _listLoadedAt =
      <_ExamListKey, DateTime>{};
  static final Map<_ExamListKey, Future<List<GeneratedExam>>> _pendingLists =
      <_ExamListKey, Future<List<GeneratedExam>>>{};
  static final Map<Object, GeneratedExam> _details = <Object, GeneratedExam>{};
  static final Map<Object, DateTime> _detailLoadedAt = <Object, DateTime>{};
  static final Map<Object, Future<GeneratedExam>> _pendingDetails =
      <Object, Future<GeneratedExam>>{};

  static Future<List<GeneratedExam>> loadList({
    required ExamService service,
    int? userId,
    int? profileId,
    bool forceRefresh = false,
  }) {
    final key = _ExamListKey(userId: userId, profileId: profileId);
    if (!forceRefresh) {
      final cached = _lists[key];
      if (cached != null) {
        return Future<List<GeneratedExam>>.value(cached);
      }
      final pending = _pendingLists[key];
      if (pending != null) {
        return pending;
      }
    }

    late final Future<List<GeneratedExam>> request;
    request = service
        .listExams(userId: userId, profileId: profileId)
        .then((exams) {
          final cachedExams = List<GeneratedExam>.unmodifiable(exams);
          _lists[key] = cachedExams;
          _listLoadedAt[key] = DateTime.now();
          for (final exam in cachedExams) {
            seedDetail(exam);
          }
          return cachedExams;
        })
        .whenComplete(() {
          if (identical(_pendingLists[key], request)) {
            _pendingLists.remove(key);
          }
        });
    _pendingLists[key] = request;
    return request;
  }

  static List<GeneratedExam>? peekList({int? userId, int? profileId}) {
    return _lists[_ExamListKey(userId: userId, profileId: profileId)];
  }

  static void seedList({
    required List<GeneratedExam> exams,
    int? userId,
    int? profileId,
  }) {
    final key = _ExamListKey(userId: userId, profileId: profileId);
    final cachedExams = List<GeneratedExam>.unmodifiable(exams);
    _lists[key] = cachedExams;
    _listLoadedAt[key] = DateTime.now();
    for (final exam in cachedExams) {
      seedDetail(exam);
    }
  }

  static bool isListFresh({
    int? userId,
    int? profileId,
    Duration maxAge = const Duration(seconds: 45),
  }) {
    final loadedAt =
        _listLoadedAt[_ExamListKey(userId: userId, profileId: profileId)];
    return loadedAt != null && DateTime.now().difference(loadedAt) <= maxAge;
  }

  static Future<GeneratedExam> loadDetail({
    required ExamDetailLoader loadDetail,
    required Object cacheKey,
    required int serviceExamId,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = _details[cacheKey];
      if (cached != null && _hasUsefulDetail(cached)) {
        return Future<GeneratedExam>.value(cached);
      }
      final pending = _pendingDetails[cacheKey];
      if (pending != null) {
        return pending;
      }
    }

    late final Future<GeneratedExam> request;
    request = _loadDetailWithEmptyResponseRetry(loadDetail, serviceExamId)
        .then((exam) {
          seedDetail(exam, fallbackCacheKey: cacheKey);
          return exam;
        })
        .whenComplete(() {
          if (identical(_pendingDetails[cacheKey], request)) {
            _pendingDetails.remove(cacheKey);
          }
        });
    _pendingDetails[cacheKey] = request;
    return request;
  }

  /// Exam generation can finish just after its metadata has been exposed by
  /// the list endpoint. Retry one empty detail response before showing an
  /// actual empty-state UI to the learner.
  static Future<GeneratedExam> _loadDetailWithEmptyResponseRetry(
    ExamDetailLoader loadDetail,
    int examId,
  ) async {
    final exam = await loadDetail(examId);
    if (exam.questions.isNotEmpty) {
      return exam;
    }

    await Future<void>.delayed(_emptyDetailRetryDelay);
    return loadDetail(examId);
  }

  static GeneratedExam? peekDetail(Object cacheKey) {
    return _details[cacheKey];
  }

  static bool isDetailFresh(
    Object cacheKey, {
    Duration maxAge = const Duration(seconds: 45),
  }) {
    final loadedAt = _detailLoadedAt[cacheKey];
    final cached = _details[cacheKey];
    return loadedAt != null &&
        cached != null &&
        _hasUsefulDetail(cached) &&
        DateTime.now().difference(loadedAt) <= maxAge;
  }

  static void seedDetail(GeneratedExam exam, {Object? fallbackCacheKey}) {
    final cacheKey = exam.examId ?? exam.id ?? fallbackCacheKey;
    if (cacheKey == null) {
      return;
    }
    final existing = _details[cacheKey];
    if (existing != null &&
        _hasUsefulDetail(existing) &&
        !_hasUsefulDetail(exam)) {
      return;
    }
    _details[cacheKey] = exam;
    _detailLoadedAt[cacheKey] = DateTime.now();
  }

  static void markSubmitted({
    required GeneratedExam exam,
    int? userId,
    int? profileId,
  }) {
    seedDetail(exam);
    final examId = exam.examId ?? exam.id;
    if (examId == null) {
      invalidateLists(userId: userId, profileId: profileId);
      return;
    }

    final updatedLists = <_ExamListKey, List<GeneratedExam>>{};
    for (final entry in _lists.entries) {
      final key = entry.key;
      if ((userId != null && key.userId != userId) ||
          (profileId != null && key.profileId != profileId)) {
        continue;
      }
      final hasExam = entry.value.any(
        (item) => (item.examId ?? item.id) == examId,
      );
      if (!hasExam) {
        continue;
      }
      updatedLists[key] = List<GeneratedExam>.unmodifiable(
        entry.value.map((item) {
          return (item.examId ?? item.id) == examId ? exam : item;
        }),
      );
      _listLoadedAt[key] = DateTime.now();
    }
    _lists.addAll(updatedLists);
  }

  static void invalidateLists({int? userId, int? profileId}) {
    _lists.removeWhere((key, _) {
      return (userId == null || key.userId == userId) &&
          (profileId == null || key.profileId == profileId);
    });
    _listLoadedAt.removeWhere((key, _) {
      return (userId == null || key.userId == userId) &&
          (profileId == null || key.profileId == profileId);
    });
    _pendingLists.removeWhere((key, _) {
      return (userId == null || key.userId == userId) &&
          (profileId == null || key.profileId == profileId);
    });
  }

  static bool _hasUsefulDetail(GeneratedExam exam) {
    return exam.questions.isNotEmpty;
  }
}

class _ExamListKey {
  const _ExamListKey({this.userId, this.profileId});

  final int? userId;
  final int? profileId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _ExamListKey &&
            other.userId == userId &&
            other.profileId == profileId;
  }

  @override
  int get hashCode => Object.hash(userId, profileId);
}
