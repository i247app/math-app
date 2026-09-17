import 'package:numi/features/notifications/models/notification.dart';

class NotificationState {
  const NotificationState({
    this.notifications = const <NotificationModel>[],
    this.isLoading = true,
    this.hasLoaded = false,
    this.errorMessage,
  });

  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
