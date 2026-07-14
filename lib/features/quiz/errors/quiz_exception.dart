class QuizException implements Exception {
  const QuizException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
