import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:numi/features/notifications/domain/models/notification.dart';
import 'package:numi/features/notifications/data/cache/notification_cache.dart';
import 'package:numi/features/notifications/application/contracts/notification_list_service.dart';

class NotificationBadgeController extends ChangeNotifier {
  NotificationBadgeController({
    required NotificationListService service,
    Stream<Object?>? incomingMessages,
  }) : _service = service,
       _incomingMessages = incomingMessages;

  final NotificationListService _service;
  final Stream<Object?>? _incomingMessages;

  StreamSubscription<Object?>? _messageSubscription;
  bool _hasUnread = false;
  bool _started = false;
  bool _disposed = false;
  int _requestRevision = 0;

  bool get hasUnread => _hasUnread;

  void start() {
    if (_started || _disposed) {
      return;
    }
    _started = true;
    final cached = NotificationCache.peek();
    if (cached != null) {
      _updateHasUnread(cached.any(_isUnread));
    }
    _messageSubscription = _incomingMessages?.listen((_) {
      _requestRevision++;
      _updateHasUnread(true);
    });
    unawaited(refresh());
  }

  Future<void> refresh() async {
    final requestRevision = ++_requestRevision;
    try {
      final notifications = await NotificationCache.load(
        service: _service,
        forceRefresh: true,
      );
      if (_disposed || requestRevision != _requestRevision) {
        return;
      }
      _updateHasUnread(notifications.any(_isUnread));
    } catch (_) {
      // Keep the current badge state when the notification endpoint is
      // temporarily unavailable.
    }
  }

  void markViewed() {
    _requestRevision++;
    _updateHasUnread(false);
  }

  bool _isUnread(NotificationModel notification) {
    final isRead = notification.isRead;
    if (isRead != null) {
      return !isRead;
    }
    return notification.readAt?.trim().isEmpty ?? true;
  }

  void _updateHasUnread(bool next) {
    if (_disposed || _hasUnread == next) {
      return;
    }
    _hasUnread = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestRevision++;
    unawaited(_messageSubscription?.cancel());
    super.dispose();
  }
}
