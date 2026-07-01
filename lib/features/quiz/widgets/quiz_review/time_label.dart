part of '../../presentation/quiz_review_screen.dart';

String _timeLabel(GeneratedQuiz quiz) {
  final parsed = DateTime.tryParse(
    quiz.modifyDt ?? quiz.createDt ?? '',
  )?.toLocal();
  if (parsed == null) {
    return '--:--';
  }
  return '${_twoDigits(parsed.hour)}:${_twoDigits(parsed.minute)}';
}
