import 'package:flutter/foundation.dart';

import 'package:numi_flutter/core/network/api_metadata.dart';
import 'package:numi_flutter/core/network/network_client.dart';
import 'package:numi_flutter/core/notifications/notification_service.dart';

abstract class NotificationPingService {
  Future<void> ping();
}

class ApiNotificationPingService implements NotificationPingService {
  ApiNotificationPingService({
    NetworkApi? networkApi,
    AppApiMetadataProvider? metadataProvider,
  }) : _networkApi = networkApi ?? NetworkApi.shared,
       _metadataProvider = metadataProvider ?? AppApiMetadataProvider.instance;

  final NetworkApi _networkApi;
  final AppApiMetadataProvider _metadataProvider;

  @override
  Future<void> ping() async {
    try {
      final latestToken = NotificationService.latestToken;
      if (latestToken != null) {
        await _metadataProvider.updateDevicePushToken(latestToken);
      }

      await _networkApi.pingNotifications();
      debugPrint('[Notification] backend ping succeeded.');
    } catch (error) {
      debugPrint('[Notification] backend ping failed: $error');
    }
  }
}

class NoopNotificationPingService implements NotificationPingService {
  const NoopNotificationPingService();

  @override
  Future<void> ping() async {}
}
