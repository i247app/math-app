import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/homework/presentation/screens/homework_review_screen.dart';

void historyOpenHomeworkResult(
  BuildContext context,
  ClassroomExercise exercise, {
  required int? profileId,
  required ClassroomExerciseService exerciseService,
}) {
  final exerciseId = exercise.stableId;
  if (exerciseId == null || profileId == null) {
    context.showErrorDialog(
      context.readText(AppKeys.studentHomeworkLoadFailed),
    );
    return;
  }

  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => HomeworkReviewScreen(
        exerciseId: exerciseId,
        profileId: profileId,
        exerciseService: exerciseService,
        initialExercise: exercise,
      ),
    ),
  );
}
