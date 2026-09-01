import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/quiz/application/read_models/history_date_value.dart';

int historyCompareQuizDescending(GeneratedQuiz first, GeneratedQuiz second) {
  final firstDate = historyDateValue(first.createDt);
  final secondDate = historyDateValue(second.createDt);
  return secondDate.compareTo(firstDate);
}
