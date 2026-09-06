class AuthException implements Exception {
  const AuthException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
