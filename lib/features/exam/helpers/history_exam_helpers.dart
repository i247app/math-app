import 'package:numi/core/helpers/api_date_time.dart';
import 'package:numi/features/exam/models/exam.dart';

DateTime historyDateValue(String? value) {
  return tryParseApiDateTime(value?.trim() ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

int historyCompareExamDescending(GeneratedExam first, GeneratedExam second) {
  final firstDate = historyDateValue(first.createDt);
  final secondDate = historyDateValue(second.createDt);
  return secondDate.compareTo(firstDate);
}

String _historyExamType(GeneratedExam exam) {
  return (exam.examType ?? '').trim().toUpperCase();
}

bool historyIsAssessmentExam(GeneratedExam exam) {
  return _historyExamType(exam) == 'ASSESSMENT';
}
