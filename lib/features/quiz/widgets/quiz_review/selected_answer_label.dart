part of '../../presentation/quiz_review_screen.dart';

String? _selectedAnswerLabel(GeneratedQuiz quiz, int questionNumber) {
  for (final answer in quiz.answers) {
    if (answer.questionNumber == questionNumber) {
      return answer.label.trim().toUpperCase();
    }
  }
  return null;
}
