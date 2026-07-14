part of 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

String? _quizReviewCorrectAnswerLabel(QuizQuestion question) {
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
