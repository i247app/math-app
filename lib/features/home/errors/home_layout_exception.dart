class HomeLayoutException implements Exception {
  const HomeLayoutException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
