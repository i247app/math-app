import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';

class TeacherStudyExerciseBatch {
  const TeacherStudyExerciseBatch({
    this.exercises = const <ClassroomExercise>[],
    this.error,
  });

  final List<ClassroomExercise> exercises;
  final String? error;
}
