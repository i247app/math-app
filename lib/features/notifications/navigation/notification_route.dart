import 'package:flutter/cupertino.dart' show CupertinoPageRoute;

import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/notifications/screens/notification_screen.dart';

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
