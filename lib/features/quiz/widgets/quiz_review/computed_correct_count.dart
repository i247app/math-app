part of '../../presentation/quiz_review_screen.dart';

int _computedCorrectCount(GeneratedQuiz quiz) {
  var count = 0;
  for (final question in quiz.questions) {
    final selected = _selectedAnswerLabel(quiz, question.questionNumber);
    final correct = _correctAnswerLabel(question);
    if (selected != null && selected == correct) {
      count++;
    }
  }
  return count;
}
