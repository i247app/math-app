part of '../../history_tab.dart';

void _historyOpenQuizReview(BuildContext context, GeneratedQuiz quiz) {
  final quizId = quiz.quizId ?? quiz.id;
  if (quizId == null) {
    context.showErrorDialog(context.readText(AppKeys.missingQuizId));
    return;
  }

  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => QuizReviewScreen(quizId: quizId, initialQuiz: quiz),
    ),
  );
}
