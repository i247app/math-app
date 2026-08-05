import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/notification_models.dart';
import 'package:numi/features/notifications/application/notification_controller.dart';
import 'package:numi/features/notifications/data/cache/notification_cache.dart';
import 'package:numi/features/notifications/data/notification_api.dart';

void main() {
  setUp(NotificationCache.invalidate);

  test('starts with loading state when no notification cache exists', () async {
    final service = _CompleterNotificationService();
    final controller = NotificationController(service: service);
    addTearDown(controller.dispose);

    expect(controller.state.isLoading, isTrue);
    expect(controller.state.hasLoaded, isFalse);

    final load = controller.load();
    service.complete([_notification(1)]);
    await load;

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.hasLoaded, isTrue);
    expect(controller.state.notifications.single.stableId, 1);
  });

  test(
    'keeps cached notifications visible during background refresh',
    () async {
      await NotificationCache.load(
        service: _FixedNotificationService([_notification(1)]),
        forceRefresh: true,
      );
      final service = _CompleterNotificationService();
      final controller = NotificationController(service: service);
      addTearDown(controller.dispose);

      expect(controller.state.hasLoaded, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.notifications.single.stableId, 1);

      final refresh = controller.load(showLoading: false);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.notifications.single.stableId, 1);

      service.complete([_notification(2)]);
      await refresh;

      expect(controller.state.notifications.single.stableId, 2);
    },
  );

  test('deduplicates concurrent notification refresh requests', () async {
    final service = _CompleterNotificationService();

    final first = NotificationCache.load(service: service, forceRefresh: true);
    final second = NotificationCache.load(service: service, forceRefresh: true);

    expect(service.callCount, 1);
    service.complete([_notification(1)]);
    await Future.wait([first, second]);

    expect(service.callCount, 1);
  });
}

NotificationModel _notification(int id) {
  return NotificationModel(rawJson: const {}, id: id, isRead: true);
}

class _FixedNotificationService implements NotificationListService {
  const _FixedNotificationService(this.notifications);

  final List<NotificationModel> notifications;

  @override
  Future<List<NotificationModel>> listNotifications() async => notifications;
}

class _CompleterNotificationService implements NotificationListService {
  final Completer<List<NotificationModel>> _completer = Completer();
  int callCount = 0;

  void complete(List<NotificationModel> notifications) {
    _completer.complete(notifications);
  }

  @override
  Future<List<NotificationModel>> listNotifications() {
    callCount++;
    return _completer.future;
  }
}
