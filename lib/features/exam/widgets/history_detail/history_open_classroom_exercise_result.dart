import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/screens/classroom_exercise_review_screen.dart';

void historyOpenClassroomExerciseResult(
  BuildContext context,
  ClassroomExercise exercise, {
  required int? profileId,
  required ClassroomExerciseService exerciseService,
}) {
  final exerciseId = exercise.stableId;
  if (exerciseId == null || profileId == null) {
    context.showErrorDialog(
      context.readText(AppKeys.studentClassroomExerciseLoadFailed),
    );
    return;
  }

  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ClassroomExerciseReviewScreen(
        exerciseId: exerciseId,
        profileId: profileId,
        exerciseService: exerciseService,
        initialExercise: exercise,
      ),
    ),
  );
}
