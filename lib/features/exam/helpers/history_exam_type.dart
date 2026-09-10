import 'package:numi/features/exam/models/exam.dart';

String historyExamType(GeneratedExam exam) {
  return (exam.examType ?? '').trim().toUpperCase();
}
