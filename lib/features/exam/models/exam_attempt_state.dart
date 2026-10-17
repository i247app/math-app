import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';

enum ExamAttemptKind {
  assessment,
  grade,
  practice,
  other;

  static ExamAttemptKind fromType(String type) =>
      switch (type.trim().toUpperCase()) {
        'ASSESSMENT' => assessment,
        'GRADE' => grade,
        'PRACTICE' => practice,
        _ => other,
      };
}

enum ExamAttemptRetryAction { generate, submit }

enum ExamAttemptSubmitStatus {
  submitted,
  missingExam,
  unanswered,
  failed,
  ignored,
}

class ExamAttemptSubmitResult {
  const ExamAttemptSubmitResult._(this.status, [this.exam]);

  const ExamAttemptSubmitResult.submitted(GeneratedExam exam)
    : this._(ExamAttemptSubmitStatus.submitted, exam);

  const ExamAttemptSubmitResult.missingExam()
    : this._(ExamAttemptSubmitStatus.missingExam);

  const ExamAttemptSubmitResult.unanswered()
    : this._(ExamAttemptSubmitStatus.unanswered);

  const ExamAttemptSubmitResult.failed()
    : this._(ExamAttemptSubmitStatus.failed);

  const ExamAttemptSubmitResult.ignored()
    : this._(ExamAttemptSubmitStatus.ignored);

  final ExamAttemptSubmitStatus status;
  final GeneratedExam? exam;
}

class AssessmentSetRecord {
  AssessmentSetRecord({
    required this.exam,
    required this.grade,
    required this.mode,
    required this.setNumber,
    required Map<int, String> selectedAnswerLabels,
    required this.correctAnswerCount,
  }) : selectedAnswerLabels = Map<int, String>.unmodifiable(
         selectedAnswerLabels,
       );

  final GeneratedExam exam;
  final int grade;
  final AssessmentFlowMode mode;
  final int setNumber;
  final Map<int, String> selectedAnswerLabels;
  final int correctAnswerCount;
}
