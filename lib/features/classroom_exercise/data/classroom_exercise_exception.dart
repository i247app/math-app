class ClassroomExerciseException implements Exception {
  const ClassroomExerciseException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
