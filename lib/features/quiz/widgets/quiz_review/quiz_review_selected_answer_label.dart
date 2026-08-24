import 'package:numi/features/quiz/data/dto/quiz_models.dart';

String? quizReviewSelectedAnswerLabel(GeneratedQuiz quiz, int questionNumber) {
  for (final answer in quiz.answers) {
    if (answer.questionNumber == questionNumber) {
      return answer.label.trim().toUpperCase();
    }
  }
  return null;
}
