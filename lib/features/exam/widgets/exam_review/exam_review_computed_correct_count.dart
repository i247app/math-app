import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_correct_answer_label.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_selected_answer_label.dart';

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
