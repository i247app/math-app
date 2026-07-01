part of '../../presentation/quiz_review_screen.dart';

String _quizReviewTimeLabel(GeneratedQuiz quiz) {
  final parsed = DateTime.tryParse(
    quiz.modifyDt ?? quiz.createDt ?? '',
  )?.toLocal();
  if (parsed == null) {
    return '--:--';
  }
  return '${_quizReviewTwoDigits(parsed.hour)}:${_quizReviewTwoDigits(parsed.minute)}';
}
