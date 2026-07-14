import 'package:flutter/material.dart';

import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/homework/homework_api.dart';
import 'package:numi/features/homework/homework_quiz_review_service.dart';
import 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

/// Homework-specific route into the shared review-detail layout.
class HomeworkReviewScreen extends StatelessWidget {
  const HomeworkReviewScreen({
    super.key,
    required this.exerciseId,
    required this.profileId,
    required this.exerciseService,
    this.initialExercise,
  });

  final int exerciseId;
  final int profileId;
  final ClassroomExerciseService exerciseService;
  final ClassroomExercise? initialExercise;

  @override
  Widget build(BuildContext context) {
    final reviewService = HomeworkQuizReviewService(
      profileId: profileId,
      exerciseService: exerciseService,
    );
    return ReviewDetailScreen(
      detailId: exerciseId,
      detailLoader: reviewService.getQuizDetail,
      initialDetail: initialExercise == null
          ? null
          : HomeworkQuizReviewService.toGeneratedQuiz(initialExercise!),
      allowRetry: false,
      // Classroom exercise and quiz ids share numeric ranges, so use a
      // separate cache namespace while preserving the real request id.
      cacheId: -exerciseId,
    );
  }
}
