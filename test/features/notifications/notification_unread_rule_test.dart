import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/notifications/controllers/notification_badge_controller.dart';
import 'package:numi/features/notifications/data/notification_api_models.dart';
import 'package:numi/features/notifications/data/notification_cache.dart';
import 'package:numi/features/notifications/data/notification_conversion.dart';
import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/notifications/models/notification.dart';
import 'package:numi/features/notifications/widgets/notification_card.dart';

const _cases = <({String name, NotificationModel notification, bool unread})>[
  (
    name: 'explicit unread with no timestamp',
    notification: NotificationModel(isRead: false),
    unread: true,
  ),
  (
    name: 'explicit unread overrides a timestamp',
    notification: NotificationModel(
      isRead: false,
      readAt: '2026-10-13T08:00:00Z',
    ),
    unread: true,
  ),
  (
    name: 'explicit read with no timestamp',
    notification: NotificationModel(isRead: true),
    unread: false,
  ),
  (
    name: 'explicit read overrides a blank timestamp',
    notification: NotificationModel(isRead: true, readAt: '  '),
    unread: false,
  ),
  (
    name: 'explicit read with a timestamp',
    notification: NotificationModel(
      isRead: true,
      readAt: '2026-10-13T08:00:00Z',
    ),
    unread: false,
  ),
  (
    name: 'missing flag and timestamp',
    notification: NotificationModel(),
    unread: true,
  ),
  (
    name: 'missing flag and empty timestamp',
    notification: NotificationModel(readAt: ''),
    unread: true,
  ),
  (
    name: 'missing flag and whitespace timestamp',
    notification: NotificationModel(readAt: '  \t\n  '),
    unread: true,
  ),
  (
    name: 'missing flag and trimmed timestamp',
    notification: NotificationModel(readAt: ' 2026-10-13T08:00:00Z '),
    unread: false,
  ),
];

void main() {
  setUp(NotificationCache.invalidate);
  tearDown(NotificationCache.invalidate);

  for (final scenario in _cases) {
    test('unread rule: ${scenario.name}', () {
      expect(scenario.notification.isUnread, scenario.unread);
    });

    testWidgets('badge and card agree: ${scenario.name}', (tester) async {
      final badge = NotificationBadgeController(
        service: _FixedService([scenario.notification]),
      );
      final lingo = LingoProvider();
      addTearDown(badge.dispose);
      addTearDown(lingo.dispose);
      await badge.refresh();
      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: NotificationCard(
                notification: scenario.notification,
                timeLabel: '',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final unreadRail = find.descendant(
        of: find.byType(NotificationCard),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.color == AppThemeColors.light.brandStrong &&
              widget.constraints?.maxWidth == 4,
        ),
      );
      expect(badge.hasUnread, scenario.unread);
      expect(unreadRail, scenario.unread ? findsOneWidget : findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  test(
    'cached unknown status starts unread and fresh read data clears the badge',
    () async {
      await NotificationCache.load(
        service: const _FixedService([
          NotificationModel(isRead: true),
          NotificationModel(),
        ]),
      );
      final request = Completer<List<NotificationModel>>();
      final badge = NotificationBadgeController(
        service: _PendingService(request.future),
      );
      addTearDown(badge.dispose);
      badge.start();
      expect(badge.hasUnread, isTrue);
      final refresh = badge.refresh();
      request.complete([const NotificationModel(isRead: true)]);
      await refresh;
      expect(badge.hasUnread, isFalse);
    },
  );

  test(
    'cached timestamp starts read and fresh unknown status shows the badge',
    () async {
      await NotificationCache.load(
        service: const _FixedService([
          NotificationModel(readAt: '2026-10-13T08:00:00Z'),
        ]),
      );
      final request = Completer<List<NotificationModel>>();
      final badge = NotificationBadgeController(
        service: _PendingService(request.future),
      );
      addTearDown(badge.dispose);
      badge.start();
      expect(badge.hasUnread, isFalse);
      final refresh = badge.refresh();
      request.complete([const NotificationModel()]);
      await refresh;
      expect(badge.hasUnread, isTrue);
    },
  );

  test(
    'wire aliases preserve flags and timestamp fallback through conversion',
    () {
      const payloads = <({Map<String, Object?> json, bool unread})>[
        (
          json: {'is_read': false, 'read_at': '2026-10-13T08:00:00Z'},
          unread: true,
        ),
        (json: {'read': 'true'}, unread: false),
        (json: {'read_status': ' unread '}, unread: true),
        (json: {'status': 'READ'}, unread: false),
        (
          json: {
            'data': {'read_at': '2026-10-13T08:00:00Z'},
          },
          unread: false,
        ),
        (json: {'read_at': '  '}, unread: true),
        (json: {}, unread: true),
      ];
      for (final payload in payloads) {
        final notification = NotificationDto.fromJson(payload.json).toModel();
        expect(
          notification.isUnread,
          payload.unread,
          reason: payload.json.toString(),
        );
      }
    },
  );
}

class _FixedService implements NotificationListService {
  const _FixedService(this.notifications);
  final List<NotificationModel> notifications;
  @override
  Future<List<NotificationModel>> listNotifications() async => notifications;
}

class _PendingService implements NotificationListService {
  const _PendingService(this.request);
  final Future<List<NotificationModel>> request;
  @override
  Future<List<NotificationModel>> listNotifications() => request;
}
