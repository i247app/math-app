import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/exam_answer_selection.dart';

String? examReviewCorrectAnswerLabel(ExamQuestion question) {
  final ids = ExamAnswerSelection.correctIds(question);
  if (ids.isEmpty) return null;
  return ExamAnswerSelection(
    optionIds: ids,
    multiple: question.isMultipleChoice,
  ).stateValue;
}

String? examReviewSelectedAnswerLabel(GeneratedExam exam, int questionNumber) {
  final question = exam.questions
      .where((q) => q.questionNumber == questionNumber)
      .firstOrNull;
  if (question == null) return null;
  final answer = exam.answers
      .where((a) => a.questionNumber == questionNumber)
      .firstOrNull;
  return answer == null
      ? null
      : ExamAnswerSelection.fromSubmitted(question, answer).stateValue;
}

bool examReviewIsCorrect(ExamQuestion question, String? selected) {
  if (question.reviewIsCorrect != null) return question.reviewIsCorrect!;
  if (selected == null) return false;
  return ExamAnswerSelection.fromState(
        question,
        selected,
      ).isCorrect(question) ==
      true;
}

int examReviewComputedCorrectCount(GeneratedExam exam) => exam.questions
    .where(
      (question) => examReviewIsCorrect(
        question,
        examReviewSelectedAnswerLabel(exam, question.questionNumber),
      ),
    )
    .length;
