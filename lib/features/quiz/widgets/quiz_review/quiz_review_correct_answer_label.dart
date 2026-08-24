import 'package:numi/features/quiz/data/dto/quiz_models.dart';

String? quizReviewCorrectAnswerLabel(QuizQuestion question) {
  final rightAnswer = question.rightAnswer?.trim();
  if (rightAnswer != null && rightAnswer.isNotEmpty) {
    return rightAnswer.toUpperCase();
  }

  final correctAnswer = question.correctAnswer?.trim();
  if (correctAnswer != null && correctAnswer.isNotEmpty) {
    return correctAnswer.toUpperCase();
  }

  return null;
}
