import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/notifications/notification_service.dart';

void main() {
  group('NotificationService.resolveMessagingToken', () {
    test('waits for an APNs token before loading the FCM token', () async {
      final calls = <String>[];
      var apnsAttempt = 0;

      final token = await NotificationService.resolveMessagingToken(
        requiresApnsToken: true,
        getApnsToken: () async {
          calls.add('apns');
          apnsAttempt++;
          return apnsAttempt == 3 ? 'apns-token' : null;
        },
        getFcmToken: () async {
          calls.add('fcm');
          return 'fcm-token';
        },
        apnsTokenLoadAttempts: 3,
        delay: (_) async {
          calls.add('delay');
        },
      );

      expect(token, 'fcm-token');
      expect(calls, <String>['apns', 'delay', 'apns', 'delay', 'apns', 'fcm']);
    });

    test('does not request an FCM token when APNs times out', () async {
      var fcmTokenRequested = false;

      final token = await NotificationService.resolveMessagingToken(
        requiresApnsToken: true,
        getApnsToken: () async => null,
        getFcmToken: () async {
          fcmTokenRequested = true;
          return 'fcm-token';
        },
        apnsTokenLoadAttempts: 2,
        delay: (_) async {},
      );

      expect(token, isNull);
      expect(fcmTokenRequested, isFalse);
    });

    test('loads the FCM token immediately on non-Apple platforms', () async {
      var apnsTokenRequested = false;

      final token = await NotificationService.resolveMessagingToken(
        requiresApnsToken: false,
        getApnsToken: () async {
          apnsTokenRequested = true;
          return null;
        },
        getFcmToken: () async => 'fcm-token',
      );

      expect(token, 'fcm-token');
      expect(apnsTokenRequested, isFalse);
    });
  });
}
