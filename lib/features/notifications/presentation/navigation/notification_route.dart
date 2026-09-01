import 'package:flutter/cupertino.dart' show CupertinoPageRoute;

import 'package:numi/features/notifications/application/contracts/notification_list_service.dart';
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
