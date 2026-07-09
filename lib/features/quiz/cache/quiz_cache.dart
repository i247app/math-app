import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/quiz_api.dart';

class QuizCache {
  QuizCache._();

  static final Map<_QuizListKey, List<GeneratedQuiz>> _lists =
      <_QuizListKey, List<GeneratedQuiz>>{};
  static final Map<_QuizListKey, DateTime> _listLoadedAt =
      <_QuizListKey, DateTime>{};
  static final Map<_QuizListKey, Future<List<GeneratedQuiz>>> _pendingLists =
      <_QuizListKey, Future<List<GeneratedQuiz>>>{};
  static final Map<int, GeneratedQuiz> _details = <int, GeneratedQuiz>{};
  static final Map<int, DateTime> _detailLoadedAt = <int, DateTime>{};
  static final Map<int, Future<GeneratedQuiz>> _pendingDetails =
      <int, Future<GeneratedQuiz>>{};

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
    required QuizService service,
    required int quizId,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = _details[quizId];
      if (cached != null && _hasUsefulDetail(cached)) {
        return Future<GeneratedQuiz>.value(cached);
      }
      final pending = _pendingDetails[quizId];
      if (pending != null) {
        return pending;
      }
    }

    late final Future<GeneratedQuiz> request;
    request = service
        .getQuizDetail(quizId)
        .then((quiz) {
          seedDetail(quiz, fallbackQuizId: quizId);
          return quiz;
        })
        .whenComplete(() {
          if (identical(_pendingDetails[quizId], request)) {
            _pendingDetails.remove(quizId);
          }
        });
    _pendingDetails[quizId] = request;
    return request;
  }

  static GeneratedQuiz? peekDetail(int quizId) {
    return _details[quizId];
  }

  static bool isDetailFresh(
    int quizId, {
    Duration maxAge = const Duration(seconds: 45),
  }) {
    final loadedAt = _detailLoadedAt[quizId];
    final cached = _details[quizId];
    return loadedAt != null &&
        cached != null &&
        _hasUsefulDetail(cached) &&
        DateTime.now().difference(loadedAt) <= maxAge;
  }

  static void seedDetail(GeneratedQuiz quiz, {int? fallbackQuizId}) {
    final quizId = quiz.quizId ?? quiz.id ?? fallbackQuizId;
    if (quizId == null) {
      return;
    }
    final existing = _details[quizId];
    if (existing != null &&
        _hasUsefulDetail(existing) &&
        !_hasUsefulDetail(quiz)) {
      return;
    }
    _details[quizId] = quiz;
    _detailLoadedAt[quizId] = DateTime.now();
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
