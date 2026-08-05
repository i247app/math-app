import 'package:numi/core/network/notification_models.dart';
import 'package:numi/features/notifications/data/notification_api.dart';

class NotificationCache {
  NotificationCache._();

  static List<NotificationModel>? _notifications;
  static Future<List<NotificationModel>>? _pending;
  static int _revision = 0;

  static List<NotificationModel>? peek() => _notifications;

  static Future<List<NotificationModel>> load({
    required NotificationListService service,
    bool forceRefresh = false,
  }) {
    final pending = _pending;
    if (pending != null) {
      return pending;
    }

    final cached = _notifications;
    if (!forceRefresh && cached != null) {
      return Future<List<NotificationModel>>.value(cached);
    }

    final requestRevision = _revision;
    late final Future<List<NotificationModel>> request;
    request = service
        .listNotifications()
        .then((notifications) {
          final result = List<NotificationModel>.unmodifiable(notifications);
          if (requestRevision == _revision) {
            _notifications = result;
          }
          return result;
        })
        .whenComplete(() {
          if (identical(_pending, request)) {
            _pending = null;
          }
        });
    _pending = request;
    return request;
  }

  static void invalidate() {
    _revision++;
    _notifications = null;
    _pending = null;
  }
}
