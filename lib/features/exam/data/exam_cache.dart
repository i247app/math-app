import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/features/exam/models/exam.dart';

typedef ExamDetailLoader = Future<GeneratedExam> Function(int detailId);

class ExamCache {
  ExamCache._();

  static const _emptyDetailRetryDelay = Duration(milliseconds: 450);

  static final Map<Object, GeneratedExam> _details = <Object, GeneratedExam>{};
  static final Map<Object, DateTime> _detailLoadedAt = <Object, DateTime>{};
  static final Map<Object, Future<GeneratedExam>> _pendingDetails =
      <Object, Future<GeneratedExam>>{};

  static Future<GeneratedExam> loadDetail({
    required ExamDetailLoader loadDetail,
    required Object cacheKey,
    required int serviceExamId,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = _details[cacheKey];
      if (cached != null &&
          cached.hasFreshImageUrls &&
          _hasUsefulDetail(cached)) {
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
          if (!identical(_pendingDetails[cacheKey], request)) return exam;
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
    final cacheScope = SessionCacheScope.current;
    final exam = await loadDetail(examId);
    if (exam.questions.isNotEmpty) {
      return exam;
    }

    await Future<void>.delayed(_emptyDetailRetryDelay);
    if (!cacheScope.isCurrent) return exam;
    return loadDetail(examId);
  }

  static GeneratedExam? peekDetail(Object cacheKey) {
    final cached = _details[cacheKey];
    return cached?.hasFreshImageUrls == true ? cached : null;
  }

  static bool isDetailFresh(
    Object cacheKey, {
    Duration maxAge = const Duration(seconds: 45),
  }) {
    final loadedAt = _detailLoadedAt[cacheKey];
    final cached = _details[cacheKey];
    return loadedAt != null &&
        cached != null &&
        cached.hasFreshImageUrls &&
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

  /// Drops all session data, including in-flight cache writes.
  static void clear() {
    _details.clear();
    _detailLoadedAt.clear();
    _pendingDetails.clear();
  }

  static bool _hasUsefulDetail(GeneratedExam exam) {
    return exam.questions.isNotEmpty;
  }
}
