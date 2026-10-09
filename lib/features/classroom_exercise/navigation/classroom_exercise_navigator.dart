import 'package:flutter/widgets.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

abstract interface class ClassroomExerciseNavigator {
  Future<void> openTeacherExercises({
    required BuildContext context,
    required int classroomId,
    required int profileId,
    required String purpose,
    int? userId,
    ClassroomModel? initialClassroom,
  });
  Future<void> openStudentExercises({
    required BuildContext context,
    required int classroomId,
    required int profileId,
  });
  Future<void> openStudentAttempt({
    required BuildContext context,
    required int exerciseId,
    required int profileId,
    required ClassroomExercise initialExercise,
  });
}
