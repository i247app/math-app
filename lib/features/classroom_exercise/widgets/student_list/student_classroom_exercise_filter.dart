import 'package:numi/core/localization/app_keys.dart';

enum StudentClassroomExerciseFilter {
  notSubmitted(AppKeys.studentClassroomExerciseNotSubmitted, 'NOT_SUBMITTED'),
  submitted(AppKeys.studentClassroomExerciseSubmitted, 'SUBMITTED'),
  overdue(AppKeys.studentClassroomExerciseOverdue, 'NOT_SUBMITTED');

  const StudentClassroomExerciseFilter(this.labelKey, this.submissionStatus);

  final String labelKey;
  final String? submissionStatus;
}
