import 'package:flutter/material.dart';

import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_exam_review_service.dart';
import 'package:numi/features/exam/screens/exam_review_screen.dart';

/// Homework-specific route into the shared review-detail layout.
class ClassroomExerciseReviewScreen extends StatelessWidget {
  const ClassroomExerciseReviewScreen({
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
    final reviewService = ClassroomExerciseExamReviewService(
      profileId: profileId,
      exerciseService: exerciseService,
    );
    return ReviewDetailScreen(
      detailId: exerciseId,
      detailLoader: reviewService.getExamDetail,
      initialDetail: initialExercise == null
          ? null
          : ClassroomExerciseExamReviewService.toGeneratedExam(
              initialExercise!,
            ),
      allowRetry: false,
      // Homework detail and submitted answers are profile-specific. A record
      // also keeps this namespace separate from integer exam cache keys.
      cacheKey: (profileId: profileId, exerciseId: exerciseId),
    );
  }
}
