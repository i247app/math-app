part of '../../presentation/student_homework_result_screen.dart';

StudentHomeworkResultSummary studentHomeworkResultSummary({
  required ClassroomExerciseSubmissionResponse submission,
}) {
  final grading = submission.grading;
  return StudentHomeworkResultSummary(
    scoreText: _homeworkScoreText(grading),
    reviewText: _homeworkReviewText(grading),
  );
}

String _homeworkScoreText(ClassroomExerciseSubmissionGrading? grading) {
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

String _homeworkReviewText(ClassroomExerciseSubmissionGrading? grading) {
  final review = grading?.aiReview?.trim();
  if (review != null && review.isNotEmpty) {
    return review;
  }

  return AppStrings.current(AppKeys.defaultAiReview);
}

void _closeHomeworkResult(BuildContext context) {
  HapticFeedback.mediumImpact();
  Navigator.of(context).pop(true);
}
