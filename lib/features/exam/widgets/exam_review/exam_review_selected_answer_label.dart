import 'package:numi/features/exam/models/exam.dart';

String? examReviewSelectedAnswerLabel(GeneratedExam exam, int questionNumber) {
  for (final answer in exam.answers) {
    if (answer.questionNumber == questionNumber) {
      return answer.label.trim().toUpperCase();
    }
  }
  return null;
}
