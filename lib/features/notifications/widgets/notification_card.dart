import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/notifications/models/notification.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/notifications/helpers/notification_display_helpers.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.timeLabel,
  });

  final NotificationModel notification;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isUnread = notification.isRead == false;
    final title = notification.title?.trim();
    final message = notificationMessage(notification);
    final radius = BorderRadius.circular(14);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: ColoredBox(
          color: colors.elevatedSurface,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isUnread) Container(width: 4, color: colors.brandStrong),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isUnread ? 14 : 18,
                      18,
                      14,
                      18,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 14,
                      children: [
                        const NotificationMascotAvatar(),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 3,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title == null || title.isEmpty
                                          ? context.getText(
                                              AppKeys.notificationFallbackTitle,
                                            )
                                          : title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.andika(
                                        color: colors.textPrimary,
                                        fontSize: FontSize.normal,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  if (timeLabel.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        timeLabel,
                                        maxLines: 1,
                                        style: GoogleFonts.andika(
                                          color: colors.textMuted,
                                          fontSize: FontSize.xxxs,
                                          fontWeight: FontWeight.w700,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                message ??
                                    context.getText(
                                      AppKeys.notificationFallbackMessage,
                                    ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: colors.textSecondary,
                                  fontSize: FontSize.compact,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationMascotAvatar extends StatelessWidget {
  const NotificationMascotAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(7),
      decoration: const BoxDecoration(
        color: AppColors.peachSoft,
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/images/numi-mascot.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class MissingChildProfileNotificationCard extends StatelessWidget {
  const MissingChildProfileNotificationCard({
    super.key,
    required this.title,
    required this.message,
    this.onTap,
  });

  final String title;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(14);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: colors.elevatedSurface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: colors.accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 12, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 14,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: colors.brandStrong.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            parentNoStudentMascotAsset,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 3,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: colors.textPrimary,
                                  fontSize: FontSize.normal,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                message,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: colors.textSecondary,
                                  fontSize: FontSize.compact,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colors.accent,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
