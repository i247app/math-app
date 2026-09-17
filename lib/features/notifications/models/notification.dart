class NotificationModel {
  const NotificationModel({
    this.id,
    this.notificationId,
    this.title,
    this.message,
    this.body,
    this.type,
    this.status,
    this.isRead,
    this.readAt,
    this.createDt,
    this.modifyDt,
  });

  final int? id;
  final int? notificationId;
  final String? title;
  final String? message;
  final String? body;
  final String? type;
  final String? status;
  final bool? isRead;
  final String? readAt;
  final String? createDt;
  final String? modifyDt;

  int? get stableId => notificationId ?? id;
}
