import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';

typedef QuizDetailLoader = Future<GeneratedQuiz> Function(int detailId);

class QuizCache {
  QuizCache._();

  static const _emptyDetailRetryDelay = Duration(milliseconds: 450);

  static final Map<_QuizListKey, List<GeneratedQuiz>> _lists =
      <_QuizListKey, List<GeneratedQuiz>>{};
  static final Map<_QuizListKey, DateTime> _listLoadedAt =
      <_QuizListKey, DateTime>{};
  static final Map<_QuizListKey, Future<List<GeneratedQuiz>>> _pendingLists =
      <_QuizListKey, Future<List<GeneratedQuiz>>>{};
  static final Map<Object, GeneratedQuiz> _details = <Object, GeneratedQuiz>{};
  static final Map<Object, DateTime> _detailLoadedAt = <Object, DateTime>{};
  static final Map<Object, Future<GeneratedQuiz>> _pendingDetails =
      <Object, Future<GeneratedQuiz>>{};

  static Future<List<GeneratedQuiz>> loadList({
    required QuizService service,
    int? userId,
    int? profileId,
    bool forceRefresh = false,
  }) {
    final key = _QuizListKey(userId: userId, profileId: profileId);
    if (!forceRefresh) {
      final cached = _lists[key];
      if (cached != null) {
        return Future<List<GeneratedQuiz>>.value(cached);
      }
      final pending = _pendingLists[key];
      if (pending != null) {
        return pending;
      }
    }

    late final Future<List<GeneratedQuiz>> request;
    request = service
        .listQuizzes(userId: userId, profileId: profileId)
        .then((quizzes) {
          final cachedQuizzes = List<GeneratedQuiz>.unmodifiable(quizzes);
          _lists[key] = cachedQuizzes;
          _listLoadedAt[key] = DateTime.now();
          for (final quiz in cachedQuizzes) {
            seedDetail(quiz);
          }
          return cachedQuizzes;
        })
        .whenComplete(() {
          if (identical(_pendingLists[key], request)) {
            _pendingLists.remove(key);
          }
        });
    _pendingLists[key] = request;
    return request;
  }

  static List<GeneratedQuiz>? peekList({int? userId, int? profileId}) {
    return _lists[_QuizListKey(userId: userId, profileId: profileId)];
  }

  static void seedList({
    required List<GeneratedQuiz> quizzes,
    int? userId,
    int? profileId,
  }) {
    final key = _QuizListKey(userId: userId, profileId: profileId);
    final cachedQuizzes = List<GeneratedQuiz>.unmodifiable(quizzes);
    _lists[key] = cachedQuizzes;
    _listLoadedAt[key] = DateTime.now();
    for (final quiz in cachedQuizzes) {
      seedDetail(quiz);
    }
  }

  static bool isListFresh({
    int? userId,
    int? profileId,
    Duration maxAge = const Duration(seconds: 45),
  }) {
    final loadedAt =
        _listLoadedAt[_QuizListKey(userId: userId, profileId: profileId)];
    return loadedAt != null && DateTime.now().difference(loadedAt) <= maxAge;
  }

  static Future<GeneratedQuiz> loadDetail({
    required QuizDetailLoader loadDetail,
    required Object cacheKey,
    required int serviceQuizId,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = _details[cacheKey];
      if (cached != null && _hasUsefulDetail(cached)) {
        return Future<GeneratedQuiz>.value(cached);
      }
      final pending = _pendingDetails[cacheKey];
      if (pending != null) {
        return pending;
      }
    }

    late final Future<GeneratedQuiz> request;
    request = _loadDetailWithEmptyResponseRetry(loadDetail, serviceQuizId)
        .then((quiz) {
          seedDetail(quiz, fallbackCacheKey: cacheKey);
          return quiz;
        })
        .whenComplete(() {
          if (identical(_pendingDetails[cacheKey], request)) {
            _pendingDetails.remove(cacheKey);
          }
        });
    _pendingDetails[cacheKey] = request;
    return request;
  }

  /// Quiz generation can finish just after its metadata has been exposed by
  /// the list endpoint. Retry one empty detail response before showing an
  /// actual empty-state UI to the learner.
  static Future<GeneratedQuiz> _loadDetailWithEmptyResponseRetry(
    QuizDetailLoader loadDetail,
    int quizId,
  ) async {
    final quiz = await loadDetail(quizId);
    if (quiz.questions.isNotEmpty) {
      return quiz;
    }

    await Future<void>.delayed(_emptyDetailRetryDelay);
    return loadDetail(quizId);
  }

  static GeneratedQuiz? peekDetail(Object cacheKey) {
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

  static void seedDetail(GeneratedQuiz quiz, {Object? fallbackCacheKey}) {
    final cacheKey = quiz.quizId ?? quiz.id ?? fallbackCacheKey;
    if (cacheKey == null) {
      return;
    }
    final existing = _details[cacheKey];
    if (existing != null &&
        _hasUsefulDetail(existing) &&
        !_hasUsefulDetail(quiz)) {
      return;
    }
    _details[cacheKey] = quiz;
    _detailLoadedAt[cacheKey] = DateTime.now();
  }

  static void markSubmitted({
    required GeneratedQuiz quiz,
    int? userId,
    int? profileId,
  }) {
    seedDetail(quiz);
    final quizId = quiz.quizId ?? quiz.id;
    if (quizId == null) {
      invalidateLists(userId: userId, profileId: profileId);
      return;
    }

    final updatedLists = <_QuizListKey, List<GeneratedQuiz>>{};
    for (final entry in _lists.entries) {
      final key = entry.key;
      if ((userId != null && key.userId != userId) ||
          (profileId != null && key.profileId != profileId)) {
        continue;
      }
      final hasQuiz = entry.value.any(
        (item) => (item.quizId ?? item.id) == quizId,
      );
      if (!hasQuiz) {
        continue;
      }
      updatedLists[key] = List<GeneratedQuiz>.unmodifiable(
        entry.value.map((item) {
          return (item.quizId ?? item.id) == quizId ? quiz : item;
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

  static bool _hasUsefulDetail(GeneratedQuiz quiz) {
    return quiz.questions.isNotEmpty;
  }
}

class _QuizListKey {
  const _QuizListKey({this.userId, this.profileId});

  final int? userId;
  final int? profileId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _QuizListKey &&
            other.userId == userId &&
            other.profileId == profileId;
  }

  @override
  int get hashCode => Object.hash(userId, profileId);
}
