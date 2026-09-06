import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/quiz/models/quiz.dart';

String assessmentResultReviewText(QuizGrading? grading) {
  final review = grading?.aiReview?.trim();
  if (review != null && review.isNotEmpty) {
    return review;
  }

  return AppStrings.current(AppKeys.defaultAiReview);
}
