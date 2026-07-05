import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/features/quiz/widgets/history_tab/history_date_value.dart';

int historyCompareQuizDescending(GeneratedQuiz first, GeneratedQuiz second) {
  final firstDate = historyDateValue(first.createDt);
  final secondDate = historyDateValue(second.createDt);
  return secondDate.compareTo(firstDate);
}
