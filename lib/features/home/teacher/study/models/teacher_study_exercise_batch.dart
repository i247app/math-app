part of '../teacher_study_tab.dart';

class _TeacherStudyExerciseBatch {
  const _TeacherStudyExerciseBatch({
    this.exercises = const <ClassroomExercise>[],
    this.error,
  });

  final List<ClassroomExercise> exercises;
  final String? error;
}
