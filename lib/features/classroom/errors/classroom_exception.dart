class ClassroomException implements Exception {
  const ClassroomException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
