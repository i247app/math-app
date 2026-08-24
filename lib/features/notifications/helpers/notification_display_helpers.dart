import 'package:flutter/widgets.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/notifications/data/dto/notification_models.dart';

typedef NotificationGroups = ({
  List<NotificationModel> today,
  List<NotificationModel> earlier,
});

NotificationGroups groupNotifications(
  List<NotificationModel> notifications, {
  DateTime? now,
}) {
  final today = <NotificationModel>[];
  final earlier = <NotificationModel>[];
  final currentTime = now ?? DateTime.now();

  for (final notification in notifications) {
    if (isNotificationToday(notification, now: currentTime)) {
      today.add(notification);
    } else {
      earlier.add(notification);
    }
  }

  return (
    today: List<NotificationModel>.unmodifiable(today),
    earlier: List<NotificationModel>.unmodifiable(earlier),
  );
}

DateTime? notificationDate(NotificationModel notification) {
  final value = notification.createDt?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  final parsed = DateTime.tryParse(value);
  if (parsed != null) {
    return parsed;
  }

  final epoch = int.tryParse(value);
  if (epoch == null) {
    return null;
  }
  return DateTime.fromMillisecondsSinceEpoch(
    epoch.abs() < 100000000000 ? epoch * 1000 : epoch,
    isUtc: true,
  );
}

bool isNotificationToday(NotificationModel notification, {DateTime? now}) {
  final date = notificationDate(notification);
  if (date == null) {
    return false;
  }
  final local = date.toLocal();
  final currentTime = now ?? DateTime.now();
  return local.year == currentTime.year &&
      local.month == currentTime.month &&
      local.day == currentTime.day;
}

String notificationTimeLabel(
  BuildContext context,
  NotificationModel notification, {
  DateTime? now,
}) {
  final date = notificationDate(notification);
  if (date == null) {
    return '';
  }

  final currentTime = now ?? DateTime.now();
  final localDate = date.toLocal();
  final difference = currentTime.difference(localDate);
  if (difference.isNegative || difference.inMinutes < 1) {
    return context.getText(AppKeys.notificationJustNow);
  }
  if (difference.inMinutes < 60) {
    return context.formatText(AppKeys.notificationMinutesAgo, {
      'count': difference.inMinutes,
    });
  }
  if (isNotificationToday(notification, now: currentTime)) {
    return context.formatText(AppKeys.notificationHoursAgo, {
      'count': difference.inHours,
    });
  }

  final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
  final notificationDay = DateTime(
    localDate.year,
    localDate.month,
    localDate.day,
  );
  final dayDifference = today.difference(notificationDay).inDays;
  if (dayDifference == 1) {
    return context.getText(AppKeys.notificationYesterday);
  }
  return context.formatText(AppKeys.notificationDaysAgo, {
    'count': dayDifference < 1 ? 1 : dayDifference,
  });
}

String? notificationMessage(NotificationModel notification) {
  final message = notification.message?.trim();
  if (message != null && message.isNotEmpty) {
    return message;
  }
  final body = notification.body?.trim();
  return body == null || body.isEmpty ? null : body;
}
