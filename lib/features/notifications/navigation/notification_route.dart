import 'package:flutter/cupertino.dart' show CupertinoPageRoute;

import 'package:numi/features/notifications/data/notification_api.dart';
import 'package:numi/features/notifications/presentation/screens/notification_screen.dart';

class NotificationRoute extends CupertinoPageRoute<bool> {
  NotificationRoute({
    NotificationListService? notificationService,
    bool showMissingChildProfileNotice = false,
  }) : super(
         builder: (_) => NotificationScreen(
           notificationService: notificationService,
           showMissingChildProfileNotice: showMissingChildProfileNotice,
         ),
       );
}
