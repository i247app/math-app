part of 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

double _quizReviewQuestionFontSize(String text) {
  final length = text.trim().length;
  if (length <= 16) {
    return 40;
  }
  if (length <= 28) {
    return 31;
  }
  return 24;
}
