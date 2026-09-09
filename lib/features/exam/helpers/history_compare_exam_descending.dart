import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/helpers/history_date_value.dart';

int historyCompareExamDescending(GeneratedExam first, GeneratedExam second) {
  final firstDate = historyDateValue(first.createDt);
  final secondDate = historyDateValue(second.createDt);
  return secondDate.compareTo(firstDate);
}
