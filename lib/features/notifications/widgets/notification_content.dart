import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/notifications/application/notification_state.dart';
import 'package:numi/features/notifications/helpers/notification_display_helpers.dart';
import 'package:numi/features/notifications/widgets/notification_loading_view.dart';
import 'package:numi/features/notifications/widgets/notification_section.dart';
import 'package:numi/features/notifications/widgets/notification_status_view.dart';

class NotificationContent extends StatelessWidget {
  const NotificationContent({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onRefresh,
  });

  final NotificationState state;
  final VoidCallback onRetry;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasLoaded) {
      return const NotificationLoadingView();
    }

    final error = state.errorMessage;
    if (error != null && state.notifications.isEmpty) {
      return NotificationStatusView(
        icon: Icons.notifications_off_outlined,
        title: context.getText(AppKeys.notificationLoadFailed),
        message: error,
        actionLabel: context.getText(AppKeys.retry),
        onAction: onRetry,
      );
    }

    if (state.notifications.isEmpty) {
      return NotificationStatusView(
        icon: Icons.notifications_none_rounded,
        title: context.getText(AppKeys.notificationEmptyTitle),
        message: context.getText(AppKeys.notificationEmptyMessage),
        onRefresh: onRefresh,
      );
    }

    final groups = groupNotifications(state.notifications);
    final sections = <Widget>[
      if (groups.today.isNotEmpty)
        NotificationSection(
          title: context.getText(AppKeys.notificationToday),
          notifications: groups.today,
          timeLabel: (notification) =>
              notificationTimeLabel(context, notification),
        ),
      if (groups.earlier.isNotEmpty)
        NotificationSection(
          title: context.getText(AppKeys.notificationEarlier),
          notifications: groups.earlier,
          timeLabel: (notification) =>
              notificationTimeLabel(context, notification),
        ),
    ];

    return RefreshIndicator(
      color: context.themeColors.brandStrong,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          28 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 26,
              children: sections,
            ),
          ),
        ),
      ),
    );
  }
}
