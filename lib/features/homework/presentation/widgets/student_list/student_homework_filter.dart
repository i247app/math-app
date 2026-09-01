import 'package:numi/core/localization/app_keys.dart';

enum StudentHomeworkFilter {
  notSubmitted(AppKeys.studentHomeworkNotSubmitted, 'NOT_SUBMITTED'),
  submitted(AppKeys.studentHomeworkSubmitted, 'SUBMITTED'),
  overdue(AppKeys.studentHomeworkOverdue, 'NOT_SUBMITTED');

  const StudentHomeworkFilter(this.labelKey, this.submissionStatus);

  final String labelKey;
  final String? submissionStatus;
}
