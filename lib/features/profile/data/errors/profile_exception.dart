class ProfileException implements Exception {
  const ProfileException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
