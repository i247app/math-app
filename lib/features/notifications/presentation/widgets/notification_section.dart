import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/features/notifications/domain/models/notification.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/notifications/presentation/widgets/notification_card.dart';

class NotificationSection extends StatelessWidget {
  const NotificationSection({
    super.key,
    required this.title,
    required this.notifications,
    required this.timeLabel,
  });

  final String title;
  final List<NotificationModel> notifications;
  final String Function(NotificationModel notification) timeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Text(
          title,
          style: GoogleFonts.andika(
            color: context.themeColors.textSecondary,
            fontSize: FontSize.normal,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        Column(
          spacing: 16,
          children: notifications
              .map(
                (notification) => NotificationCard(
                  notification: notification,
                  timeLabel: timeLabel(notification),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class MissingChildProfileNotificationSection extends StatelessWidget {
  const MissingChildProfileNotificationSection({
    super.key,
    required this.title,
    this.onCreateProfile,
  });

  final String title;
  final VoidCallback? onCreateProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Text(
          title,
          style: GoogleFonts.andika(
            color: context.themeColors.textSecondary,
            fontSize: FontSize.normal,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        MissingChildProfileNotificationCard(
          title: context.getText(AppKeys.parentNoStudentTitle),
          message: context.getText(AppKeys.parentNoStudentMessage),
          onTap: onCreateProfile,
        ),
      ],
    );
  }
}
