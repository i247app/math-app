part of '../../history_tab.dart';

int _compareQuizHistoryDescending(GeneratedQuiz first, GeneratedQuiz second) {
  final firstDate = _historyDateValue(first.createDt);
  final secondDate = _historyDateValue(second.createDt);
  return secondDate.compareTo(firstDate);
}
