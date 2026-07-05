import 'package:numi_flutter/core/network/classroom_exercise_models.dart';

String historyHomeworkDateText(ClassroomExercise exercise) {
  final values = <String?>[
    exercise.modifyDt,
    exercise.createDt,
    exercise.endDate,
    exercise.startDate,
  ];
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return '';
}
