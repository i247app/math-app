import 'package:numi_flutter/core/network/chapter_models.dart';
import 'package:numi_flutter/features/quiz/chapter_api.dart';

class ReviewChapterCache {
  ReviewChapterCache._();

  static final Map<_ReviewChapterKey, List<ChapterModel>> _chapters =
      <_ReviewChapterKey, List<ChapterModel>>{};
  static final Map<_ReviewChapterKey, DateTime> _loadedAt =
      <_ReviewChapterKey, DateTime>{};
  static final Map<_ReviewChapterKey, Future<List<ChapterModel>>> _pending =
      <_ReviewChapterKey, Future<List<ChapterModel>>>{};

  static Future<List<ChapterModel>> loadChapters({
    required ChapterService service,
    required int programId,
    required int gradeId,
    required int semesterId,
    bool forceRefresh = false,
  }) {
    final key = _ReviewChapterKey(
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
    return _chapters[_ReviewChapterKey(
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
        _loadedAt[_ReviewChapterKey(
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
    final key = _ReviewChapterKey(
      programId: programId,
      gradeId: gradeId,
      semesterId: semesterId,
    );
    _chapters.remove(key);
    _loadedAt.remove(key);
    _pending.remove(key);
  }
}

class _ReviewChapterKey {
  const _ReviewChapterKey({
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
        other is _ReviewChapterKey &&
            other.programId == programId &&
            other.gradeId == gradeId &&
            other.semesterId == semesterId;
  }

  @override
  int get hashCode => Object.hash(programId, gradeId, semesterId);
}
