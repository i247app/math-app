part of '../../history_tab.dart';

String _historyQuizPurpose(GeneratedQuiz quiz) {
  final purpose = quiz.purpose?.trim();
  if (purpose != null && purpose.isNotEmpty) {
    return purpose.toUpperCase();
  }
  return (quiz.type ?? '').trim().toUpperCase();
}
