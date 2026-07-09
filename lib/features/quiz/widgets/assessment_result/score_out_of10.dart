import 'package:numi/core/network/quiz_models.dart';

int scoreOutOf10(QuizGrading? grading) {
  final scorePercentage = grading?.scorePercentage;
  if (scorePercentage != null) {
    return (scorePercentage / 10).round().clamp(0, 10);
  }

  return 10;
}
