class ExamException implements Exception {
  const ExamException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
