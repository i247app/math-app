import 'package:flutter/material.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/navigation/classroom_exercise_navigator.dart';
import 'package:numi/features/classroom_exercise/screens/teacher_classroom_exercise_screen.dart';
import 'package:numi/features/classroom_exercise/screens/student_classroom_exercise_screen.dart';
import 'package:numi/features/classroom_exercise/screens/student_classroom_exercise_attempt_screen.dart';

class AppClassroomExerciseNavigator implements ClassroomExerciseNavigator {
  const AppClassroomExerciseNavigator();

  @override
  Future<void> openTeacherExercises({
    required BuildContext context,
    required int classroomId,
    required int profileId,
    required String purpose,
    int? userId,
    ClassroomModel? initialClassroom,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => TeacherClassroomExerciseScreen(
        classroomId: classroomId,
        profileId: profileId,
        purpose: purpose,
        userId: userId,
        initialClassroom: initialClassroom,
      ),
    ),
  );

  @override
  Future<void> openStudentExercises({
    required BuildContext context,
    required int classroomId,
    required int profileId,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => StudentClassroomExerciseScreen(
        classroomId: classroomId,
        profileId: profileId,
      ),
    ),
  );

  @override
  Future<void> openStudentAttempt({
    required BuildContext context,
    required int exerciseId,
    required int profileId,
    required ClassroomExercise initialExercise,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => StudentClassroomExerciseAttemptScreen(
        exerciseId: exerciseId,
        profileId: profileId,
        initialExercise: initialExercise,
      ),
    ),
  );
}
