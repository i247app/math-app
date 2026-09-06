import 'package:numi/features/quiz/models/quiz.dart';

abstract interface class QuizSnapshotStore {
  void seedList({
    required List<GeneratedQuiz> quizzes,
    int? userId,
    int? profileId,
  });
}

class NoopQuizSnapshotStore implements QuizSnapshotStore {
  const NoopQuizSnapshotStore();

  @override
  void seedList({
    required List<GeneratedQuiz> quizzes,
    int? userId,
    int? profileId,
  }) {}
}
