import 'package:numi/core/debug/app_logger.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/notifications/notification_service.dart';
import 'package:numi/features/notifications/data/notification_ping_service.dart';

class ApiNotificationPingService implements NotificationPingService {
  ApiNotificationPingService({
    NetworkClient? networkClient,
    AppApiMetadataProvider? metadataProvider,
  }) : _networkClient = networkClient ?? NetworkClient.shared,
       _metadataProvider = metadataProvider ?? AppApiMetadataProvider.instance;

  final NetworkClient _networkClient;
  final AppApiMetadataProvider _metadataProvider;

  @override
  Future<void> ping() async {
    try {
      final pushToken = await NotificationService.currentToken();
      if (pushToken != null) {
        await _metadataProvider.updateDevicePushToken(pushToken);
      }

      final json = await _networkClient.postJson(
        '/notifications/ping',
        const <String, dynamic>{},
      );
      NetworkClient.throwForApiStatus(json);
      AppLogger.info('NOTIFY', 'backend ping succeeded');
    } catch (error) {
      AppLogger.error('NOTIFY', 'backend ping failed', error: error);
    }
  }
}

class NoopNotificationPingService implements NotificationPingService {
  const NoopNotificationPingService();

  @override
  Future<void> ping() async {}
}
