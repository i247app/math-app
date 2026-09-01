import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:numi/features/notifications/domain/models/notification.dart';
import 'package:numi/features/notifications/application/read_models/notification_badge_controller.dart';
import 'package:numi/features/notifications/data/cache/notification_cache.dart';
import 'package:numi/features/notifications/application/contracts/notification_list_service.dart';

void main() {
  setUp(NotificationCache.invalidate);

  test(
    'shows the badge when the API contains an unread notification',
    () async {
      final controller = NotificationBadgeController(
        service: const _FakeNotificationService([
          NotificationModel(id: 1, isRead: false),
        ]),
      );
      addTearDown(controller.dispose);

      await controller.refresh();

      expect(controller.hasUnread, isTrue);
    },
  );

  test('does not show the badge when every notification is read', () async {
    final controller = NotificationBadgeController(
      service: const _FakeNotificationService([
        NotificationModel(id: 1, isRead: true),
        NotificationModel(id: 2, readAt: '2026-07-30T08:00:00Z'),
      ]),
    );
    addTearDown(controller.dispose);

    await controller.refresh();

    expect(controller.hasUnread, isFalse);
  });

  test('shows the badge again when a new message arrives', () async {
    final messages = StreamController<Object?>.broadcast();
    final controller = NotificationBadgeController(
      service: const _FakeNotificationService([]),
      incomingMessages: messages.stream,
    );
    addTearDown(() async {
      controller.dispose();
      await messages.close();
    });

    controller.start();
    await Future<void>.delayed(Duration.zero);
    controller.markViewed();
    messages.add(const Object());
    await Future<void>.delayed(Duration.zero);

    expect(controller.hasUnread, isTrue);
  });
}

class _FakeNotificationService implements NotificationListService {
  const _FakeNotificationService(this.notifications);

  final List<NotificationModel> notifications;

  @override
  Future<List<NotificationModel>> listNotifications() async => notifications;
}
