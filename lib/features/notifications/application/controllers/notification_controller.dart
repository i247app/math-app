import 'package:flutter/foundation.dart';

import 'package:numi/features/notifications/domain/models/notification.dart';
import 'package:numi/features/notifications/application/controllers/notification_state.dart';
import 'package:numi/features/notifications/data/cache/notification_cache.dart';
import 'package:numi/features/notifications/application/contracts/notification_list_service.dart';
import 'package:numi/features/notifications/application/errors/notification_list_exception.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({required NotificationListService service})
    : _service = service,
      _state = _initialState();

  final NotificationListService _service;

  NotificationState _state;
  NotificationState get state => _state;

  int _requestRevision = 0;
  bool _disposed = false;

  Future<void> load({bool showLoading = true}) async {
    final requestRevision = ++_requestRevision;
    if (showLoading) {
      _update(_state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final notifications = await NotificationCache.load(
        service: _service,
        forceRefresh: true,
      );
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

  static NotificationState _initialState() {
    final cached = NotificationCache.peek();
    if (cached == null) {
      return const NotificationState();
    }
    return NotificationState(
      notifications: cached,
      isLoading: false,
      hasLoaded: true,
    );
  }

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
