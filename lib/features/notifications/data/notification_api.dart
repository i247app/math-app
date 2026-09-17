import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/notifications/data/notification_api_models.dart';
import 'package:numi/features/notifications/data/notification_conversion.dart';
import 'package:numi/features/notifications/models/notification.dart';
import 'package:numi/features/notifications/data/notification_list_exception.dart';

class NotificationApi implements NotificationListService {
  NotificationApi({String? baseUrl, NetworkClient? networkClient})
    : _networkClient =
          networkClient ??
          (baseUrl == null
              ? NetworkClient.shared
              : NetworkClient(baseUrl: baseUrl));

  final NetworkClient _networkClient;

  @override
  Future<List<NotificationModel>> listNotifications() async {
    try {
      final json = await _networkClient.postJson(
        '/notifications/list',
        const NotificationListRequest().toJson(),
      );
      NetworkClient.throwForApiStatus(json);
      final response = NotificationListResponse.fromJson(json);
      return response.notifications
          .map((notification) => notification.toModel())
          .toList();
    } on NetworkException catch (error) {
      throw NotificationListException(error.message, status: error.status);
    }
  }
}
