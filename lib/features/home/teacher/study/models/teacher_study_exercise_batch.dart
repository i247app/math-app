part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherStudyExerciseBatch {
  const _TeacherStudyExerciseBatch({
    this.exercises = const <ClassroomExercise>[],
    this.error,
  });

  final List<ClassroomExercise> exercises;
  final String? error;
}
