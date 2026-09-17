class SchoolException implements Exception {
  const SchoolException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
