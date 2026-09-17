import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/helpers/history_exam_type.dart';

bool historyIsAssessmentExam(GeneratedExam exam) {
  return historyExamType(exam) == 'ASSESSMENT';
}
