part of '../../presentation/quiz_review_screen.dart';

int _quizReviewComputedCorrectCount(GeneratedQuiz quiz) {
  var count = 0;
  for (final question in quiz.questions) {
    final selected = _quizReviewSelectedAnswerLabel(
      quiz,
      question.questionNumber,
    );
    final correct = _quizReviewCorrectAnswerLabel(question);
    if (selected != null && selected == correct) {
      count++;
    }
  }
  return count;
}
