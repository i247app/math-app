import 'package:numi/features/quiz/models/quiz.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_correct_answer_label.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_selected_answer_label.dart';

int quizReviewComputedCorrectCount(GeneratedQuiz quiz) {
  var count = 0;
  for (final question in quiz.questions) {
    final selected = quizReviewSelectedAnswerLabel(
      quiz,
      question.questionNumber,
    );
    final correct = quizReviewCorrectAnswerLabel(question);
    if (selected != null && selected == correct) {
      count++;
    }
  }
  return count;
}
