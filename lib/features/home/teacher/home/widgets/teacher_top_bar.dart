import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/notifications/widgets/notification_unread_dot.dart';
import 'package:numi/features/profile/widgets/profile_avatar_image.dart';
import 'package:numi/shared/helpers/teacher_display_helpers.dart';

class TeacherTopBar extends StatelessWidget {
  const TeacherTopBar({
    super.key,
    required this.profile,
    required this.topPadding,
    required this.onNotificationTap,
    this.hasUnreadNotifications = false,
  });

  final StudentProfile? profile;
  final double topPadding;
  final VoidCallback onNotificationTap;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final name = displayTeacherName(profile);
    final colors = context.themeColors;
    return Container(
      padding: EdgeInsets.fromLTRB(18, topPadding + 16, 18, 14),
      decoration: BoxDecoration(color: colors.pageBackgroundTop),
      child: Row(
        spacing: 12,
        children: [
          ProfileAvatarImage(
            size: 48,
            avatarKey: profile?.avatarKey,
            avatarUrl: profile?.avatarUrl,
            borderColor: AppColors.navy900.withValues(alpha: 0.10),
            borderWidth: 2,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getText(AppKeys.teacherWelcomeBack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: colors.textSecondary,
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    height: 1.25,
                  ),
                ),
                Text(
                  '$name 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: colors.textPrimary,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: context.getText(AppKeys.notificationTitle),
            child: Material(
              color: colors.elevatedSurface,
              elevation: 1,
              shadowColor: colors.shadow,
              shape: CircleBorder(side: BorderSide(color: colors.border)),
              child: InkWell(
                onTap: onNotificationTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: colors.brandStrong,
                        size: 22,
                      ),
                      if (hasUnreadNotifications)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: NotificationUnreadDot(
                            borderColor: colors.elevatedSurface,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
