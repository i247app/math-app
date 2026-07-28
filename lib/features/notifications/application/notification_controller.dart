import 'package:flutter/foundation.dart';

import 'package:numi/core/network/notification_models.dart';
import 'package:numi/features/notifications/application/notification_state.dart';
import 'package:numi/features/notifications/data/notification_api.dart';
import 'package:numi/features/notifications/errors/notification_list_exception.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({required NotificationListService service})
    : _service = service;

  final NotificationListService _service;

  NotificationState _state = const NotificationState();
  NotificationState get state => _state;

  int _requestRevision = 0;
  bool _disposed = false;

  Future<void> load({bool showLoading = true}) async {
    final requestRevision = ++_requestRevision;
    if (showLoading) {
      _update(_state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final notifications = await _service.listNotifications();
      if (_disposed || requestRevision != _requestRevision) {
        return;
      }
      _update(
        NotificationState(
          notifications: List<NotificationModel>.unmodifiable(notifications),
          isLoading: false,
          hasLoaded: true,
        ),
      );
    } on NotificationListException catch (error) {
      _handleFailure(requestRevision, error.message);
    } catch (error) {
      _handleFailure(requestRevision, error.toString());
    }
  }

  Future<void> refresh() => load(showLoading: false);

  void _handleFailure(int requestRevision, String message) {
    if (_disposed || requestRevision != _requestRevision) {
      return;
    }
    _update(
      _state.copyWith(isLoading: false, hasLoaded: true, errorMessage: message),
    );
  }

  void _update(NotificationState next) {
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestRevision++;
    super.dispose();
  }
}
