import 'package:numi/features/quiz/data/quiz_snapshot_store.dart';
import 'package:numi/features/quiz/data/quiz_cache.dart';
import 'package:numi/features/quiz/models/quiz.dart';

class CachedQuizSnapshotStore implements QuizSnapshotStore {
  const CachedQuizSnapshotStore();

  @override
  void seedList({
    required List<GeneratedQuiz> quizzes,
    int? userId,
    int? profileId,
  }) {
    QuizCache.seedList(quizzes: quizzes, userId: userId, profileId: profileId);
  }
}
