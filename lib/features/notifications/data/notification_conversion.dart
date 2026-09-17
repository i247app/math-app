import 'package:numi/features/notifications/data/notification_api_models.dart';
import 'package:numi/features/notifications/models/notification.dart';

extension NotificationDtoConversion on NotificationDto {
  NotificationModel toModel() => NotificationModel(
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
