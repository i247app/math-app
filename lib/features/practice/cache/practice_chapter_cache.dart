import 'package:numi/core/network/chapter_models.dart';
import 'package:numi/features/practice/practice_api.dart';

class PracticeChapterCache {
  PracticeChapterCache._();

  static final Map<_PracticeChapterKey, List<ChapterModel>> _chapters =
      <_PracticeChapterKey, List<ChapterModel>>{};
  static final Map<_PracticeChapterKey, DateTime> _loadedAt =
      <_PracticeChapterKey, DateTime>{};
  static final Map<_PracticeChapterKey, Future<List<ChapterModel>>> _pending =
      <_PracticeChapterKey, Future<List<ChapterModel>>>{};

  static Future<List<ChapterModel>> loadChapters({
    required PracticeService service,
    required int programId,
    required int gradeId,
    required int semesterId,
    bool forceRefresh = false,
  }) {
    final key = _PracticeChapterKey(
      programId: programId,
      gradeId: gradeId,
      semesterId: semesterId,
    );
    if (!forceRefresh) {
      final cached = _chapters[key];
      if (cached != null) {
        return Future<List<ChapterModel>>.value(cached);
      }
      final pending = _pending[key];
      if (pending != null) {
        return pending;
      }
    }

    late final Future<List<ChapterModel>> request;
    request = service
        .listChapters(
          programId: programId,
          gradeId: gradeId,
          semesterId: semesterId,
        )
        .then((chapters) {
          final cachedChapters = List<ChapterModel>.unmodifiable(chapters);
          _chapters[key] = cachedChapters;
          _loadedAt[key] = DateTime.now();
          return cachedChapters;
        })
        .whenComplete(() {
          if (identical(_pending[key], request)) {
            _pending.remove(key);
          }
        });
    _pending[key] = request;
    return request;
  }

  static List<ChapterModel>? peekChapters({
    required int programId,
    required int gradeId,
    required int semesterId,
  }) {
    return _chapters[_PracticeChapterKey(
      programId: programId,
      gradeId: gradeId,
      semesterId: semesterId,
    )];
  }

  static bool isFresh({
    required int programId,
    required int gradeId,
    required int semesterId,
    Duration maxAge = const Duration(minutes: 5),
  }) {
    final loadedAt =
        _loadedAt[_PracticeChapterKey(
          programId: programId,
          gradeId: gradeId,
          semesterId: semesterId,
        )];
    return loadedAt != null && DateTime.now().difference(loadedAt) <= maxAge;
  }

  static void invalidate({
    required int programId,
    required int gradeId,
    required int semesterId,
  }) {
    final key = _PracticeChapterKey(
      programId: programId,
      gradeId: gradeId,
      semesterId: semesterId,
    );
    _chapters.remove(key);
    _loadedAt.remove(key);
    _pending.remove(key);
  }
}

class _PracticeChapterKey {
  const _PracticeChapterKey({
    required this.programId,
    required this.gradeId,
    required this.semesterId,
  });

  final int programId;
  final int gradeId;
  final int semesterId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _PracticeChapterKey &&
            other.programId == programId &&
            other.gradeId == gradeId &&
            other.semesterId == semesterId;
  }

  @override
  int get hashCode => Object.hash(programId, gradeId, semesterId);
}
