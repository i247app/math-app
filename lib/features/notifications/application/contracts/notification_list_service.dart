import 'package:numi/features/notifications/domain/models/notification.dart';

abstract interface class NotificationListService {
  Future<List<NotificationModel>> listNotifications();
}
