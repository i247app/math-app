import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

const notificationUnreadDotKey = Key('notification-unread-dot');

class NotificationUnreadDot extends StatelessWidget {
  const NotificationUnreadDot({
    super.key,
    required this.borderColor,
    this.size = 9,
  });

  final Color borderColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: notificationUnreadDotKey,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.coral600,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.25),
      ),
    );
  }
}
