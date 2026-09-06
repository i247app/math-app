import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

String historyClassroomExerciseDateText(ClassroomExercise exercise) {
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
