import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/widgets/student_result/student_classroom_exercise_result_summary.dart';

StudentClassroomExerciseResultSummary studentClassroomExerciseResultSummary({
  required ClassroomExerciseSubmissionResponse submission,
}) {
  final grading = submission.grading;
  return StudentClassroomExerciseResultSummary(
    scoreText: _classroomExerciseScoreText(grading),
    reviewText: _classroomExerciseReviewText(grading),
  );
}

String _classroomExerciseScoreText(
  ClassroomExerciseSubmissionGrading? grading,
) {
  final scorePercentage = grading?.scorePercentage;
  if (scorePercentage != null) {
    final scoreOutOf10 = (scorePercentage / 10).round().clamp(0, 10);
    return '$scoreOutOf10/10';
  }

  final correctNumber = grading?.correctNumber;
  final totalQuestions = grading?.totalQuestions;
  if (correctNumber != null && totalQuestions != null && totalQuestions > 0) {
    final scoreOutOf10 = (correctNumber / totalQuestions * 10).round();
    return '${scoreOutOf10.clamp(0, 10)}/10';
  }

  return '--/10';
}

String _classroomExerciseReviewText(
  ClassroomExerciseSubmissionGrading? grading,
) {
  final review = grading?.aiReview?.trim();
  if (review != null && review.isNotEmpty) {
    return review;
  }

  return AppStrings.current(AppKeys.defaultAiReview);
}

void closeStudentClassroomExerciseResult(BuildContext context) {
  HapticFeedback.mediumImpact();
  Navigator.of(context).pop(true);
}
