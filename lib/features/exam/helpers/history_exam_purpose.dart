import 'package:numi/features/exam/models/exam.dart';

String historyExamPurpose(GeneratedExam exam) {
  final purpose = exam.purpose?.trim();
  if (purpose != null && purpose.isNotEmpty) {
    return purpose.toUpperCase();
  }
  return (exam.type ?? '').trim().toUpperCase();
}
