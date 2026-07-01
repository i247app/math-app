part of '../../presentation/assessment_result_screen.dart';

String _reviewText(QuizGrading? grading) {
  final review = grading?.aiReview?.trim();
  if (review != null && review.isNotEmpty) {
    return review;
  }

  return AppStrings.current(AppKeys.defaultAiReview);
}
