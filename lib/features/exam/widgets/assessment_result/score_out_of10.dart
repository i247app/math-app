import 'package:numi/features/exam/models/exam.dart';

int scoreOutOf10(ExamGrading? grading) {
  final scorePercentage = grading?.scorePercentage;
  if (scorePercentage != null) {
    return (scorePercentage / 10).round().clamp(0, 10);
  }

  return 10;
}
