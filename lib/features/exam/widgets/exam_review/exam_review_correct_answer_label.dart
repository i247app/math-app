import 'package:numi/features/exam/models/exam.dart';

String? examReviewCorrectAnswerLabel(ExamQuestion question) {
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
