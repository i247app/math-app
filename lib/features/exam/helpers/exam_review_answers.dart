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

String? examReviewSelectedAnswerLabel(GeneratedExam exam, int questionNumber) {
  for (final answer in exam.answers) {
    if (answer.questionNumber == questionNumber) {
      return answer.label.trim().toUpperCase();
    }
  }
  return null;
}

int examReviewComputedCorrectCount(GeneratedExam exam) {
  var count = 0;
  for (final question in exam.questions) {
    final selected = examReviewSelectedAnswerLabel(
      exam,
      question.questionNumber,
    );
    final correct = examReviewCorrectAnswerLabel(question);
    if (selected != null && selected == correct) {
      count++;
    }
  }
  return count;
}
