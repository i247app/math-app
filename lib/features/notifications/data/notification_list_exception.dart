class NotificationListException implements Exception {
  const NotificationListException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}
