part of '../../presentation/student_homework_screen.dart';

enum _StudentHomeworkFilter {
  notSubmitted(AppKeys.studentHomeworkNotSubmitted, 'NOT_SUBMITTED'),
  submitted(AppKeys.studentHomeworkSubmitted, 'SUBMITTED'),
  overdue(AppKeys.studentHomeworkOverdue, 'NOT_SUBMITTED');

  const _StudentHomeworkFilter(this.labelKey, this.submissionStatus);

  final String labelKey;
  final String? submissionStatus;
}
