import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/helpers/history_date_value.dart';

int historyCompareQuizDescending(GeneratedQuiz first, GeneratedQuiz second) {
  final firstDate = historyDateValue(first.createDt);
  final secondDate = historyDateValue(second.createDt);
  return secondDate.compareTo(firstDate);
}
