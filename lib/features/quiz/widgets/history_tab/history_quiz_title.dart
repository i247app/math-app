part of 'package:numi/features/quiz/presentation/tabs/history_tab.dart';

String _historyQuizTitle(BuildContext context, GeneratedQuiz quiz) {
  if (quiz.title != null && quiz.title!.trim().isNotEmpty) {
    return quiz.title!;
  }

  final grade = quiz.grading?.aiDetectGrade?.trim();
  final suffix = grade != null && grade.isNotEmpty ? ' $grade' : '';
  final type = historyQuizPurpose(quiz);

  if (type == 'ASSESSMENT') {
    return '${context.getText(AppKeys.mathAssessment)}$suffix';
  }
  if (type == 'PRACTICE') {
    return '${context.getText(AppKeys.mathPractice)}$suffix';
  }
  return '${context.getText(AppKeys.mathReview)}$suffix';
}
