import 'package:numi/features/notifications/data/dto/notification_models.dart';
import 'package:numi/features/notifications/domain/models/notification.dart';

extension NotificationDtoMapper on NotificationDto {
  NotificationModel toDomain() => NotificationModel(
    id: id,
    notificationId: notificationId,
    title: title,
    message: message,
    body: body,
    type: type,
    status: status,
    isRead: isRead,
    readAt: readAt,
    createDt: createDt,
    modifyDt: modifyDt,
  );
}
