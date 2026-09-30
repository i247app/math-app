import 'package:numi/features/exam/helpers/grade_exam_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';

class GradeExamCompletion {
  const GradeExamCompletion({
    required this.exam,
    required this.grade,
    required this.level,
    required this.outcome,
  });

  final GeneratedExam exam;
  final int grade;
  final int level;
  final GradeExamOutcome outcome;
}
