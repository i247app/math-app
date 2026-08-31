import 'package:numi/features/homework/domain/models/classroom_exercise.dart';

class TeacherStudyExerciseBatch {
  const TeacherStudyExerciseBatch({
    this.exercises = const <ClassroomExercise>[],
    this.error,
  });

  final List<ClassroomExercise> exercises;
  final String? error;
}
