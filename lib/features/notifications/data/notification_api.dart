import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/network/notification_models.dart';

class NotificationListException implements Exception {
  const NotificationListException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class NotificationListService {
  Future<List<NotificationModel>> listNotifications();
}

class NotificationApi implements NotificationListService {
  NotificationApi({String? baseUrl, NetworkApi? networkApi})
    : _networkApi =
          networkApi ??
          (baseUrl == null ? NetworkApi.shared : NetworkApi(baseUrl: baseUrl));

  final NetworkApi _networkApi;

  @override
  Future<List<NotificationModel>> listNotifications() async {
    try {
      final response = await _networkApi.listNotifications();
      return response.notifications;
    } on NetworkException catch (error) {
      throw NotificationListException(error.message, status: error.status);
    }
  }
}
