class GradeException implements Exception {
  const GradeException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
