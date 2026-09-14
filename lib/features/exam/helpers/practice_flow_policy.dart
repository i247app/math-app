class PracticeSetScore {
  PracticeSetScore({
    required this.totalQuestions,
    required Set<int> answeredQuestionIndexes,
    required Set<int> correctQuestionIndexes,
  }) : answeredQuestionIndexes = Set<int>.unmodifiable(answeredQuestionIndexes),
       correctQuestionIndexes = Set<int>.unmodifiable(correctQuestionIndexes);

  final int totalQuestions;
  final Set<int> answeredQuestionIndexes;
  final Set<int> correctQuestionIndexes;

  int get answeredCount => answeredQuestionIndexes.length;

  int get correctCount =>
      answeredQuestionIndexes.where(correctQuestionIndexes.contains).length;

  int get wrongCount => answeredCount - correctCount;

  bool get isComplete => totalQuestions > 0 && answeredCount >= totalQuestions;

  bool areFirstQuestionsPerfect(int count) {
    if (totalQuestions < count || count <= 0) {
      return false;
    }
    for (var index = 0; index < count; index++) {
      if (!answeredQuestionIndexes.contains(index) ||
          !correctQuestionIndexes.contains(index)) {
        return false;
      }
    }
    return true;
  }
}

/// A practice set keeps its generated grade and ends only when one of the
/// placement-style confidence boundaries is known from first attempts.
class PracticeFlowPolicy {
  const PracticeFlowPolicy._();

  static const int firstCorrectAnswerTarget = 6;

  static bool shouldSubmit(PracticeSetScore score) {
    return score.areFirstQuestionsPerfect(firstCorrectAnswerTarget) ||
        score.wrongCount * 2 > score.totalQuestions ||
        score.isComplete;
  }
}
