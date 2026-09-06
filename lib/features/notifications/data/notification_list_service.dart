import 'package:numi/features/notifications/models/notification.dart';

abstract interface class NotificationListService {
  Future<List<NotificationModel>> listNotifications();
}
