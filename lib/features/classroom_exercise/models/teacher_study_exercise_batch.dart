import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

class TeacherStudyExerciseBatch {
  const TeacherStudyExerciseBatch({
    this.exercises = const <ClassroomExercise>[],
    this.error,
  });

  final List<ClassroomExercise> exercises;
  final String? error;
}
