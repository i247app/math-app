import 'package:numi/features/notifications/data/dto/notification_models.dart';

abstract interface class NotificationListService {
  Future<List<NotificationModel>> listNotifications();
}
