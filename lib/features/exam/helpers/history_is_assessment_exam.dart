import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/helpers/history_exam_purpose.dart';

bool historyIsAssessmentExam(GeneratedExam exam) {
  return historyExamPurpose(exam) == 'ASSESSMENT';
}
