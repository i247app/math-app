import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/widgets/notification_unread_dot.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/profile/domain/models/profile_role.dart';
import 'package:numi/shared/widgets/profile_avatar_image.dart';

String mainShellRoleLabel(BuildContext context, ProfileRole role) {
  return switch (role) {
    ProfileRole.parent => context.getText(AppKeys.roleParent).toUpperCase(),
    ProfileRole.teacher => context.getText(AppKeys.roleTeacher).toUpperCase(),
    ProfileRole.student => context.getText(AppKeys.roleStudent).toUpperCase(),
  };
}

class DashboardHeaderBar extends StatelessWidget {
  const DashboardHeaderBar({
    super.key,
    required this.topInset,
    required this.name,
    required this.profile,
    required this.role,
    required this.canSwitchProfile,
    required this.isProfileMenuOpen,
    required this.parentStreakCount,
    required this.onProfileTap,
    required this.onNotificationTap,
    this.hasUnreadNotifications = false,
  });

  final double topInset;
  final String name;
  final StudentProfile? profile;
  final ProfileRole role;
  final bool canSwitchProfile;
  final bool isProfileMenuOpen;
  final int parentStreakCount;
  final VoidCallback? onProfileTap;
  final VoidCallback onNotificationTap;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return RepaintBoundary(
      child: Container(
        height: topInset + 64,
        padding: EdgeInsets.fromLTRB(14, topInset + 6, 14, 6),
        decoration: BoxDecoration(color: colors.elevatedSurface),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: canSwitchProfile,
                child: InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 9,
                    children: [
                      DashboardProfileAvatar(
                        size: 37,
                        avatarKey: profile?.avatarKey,
                        avatarUrl: profile?.avatarUrl,
                        showStatus: role != ProfileRole.parent,
                        borderColor: role == ProfileRole.parent
                            ? colors.accent.withValues(alpha: 0.35)
                            : null,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              mainShellRoleLabel(context, role),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: FontSize.small,
                                fontWeight: FontWeight.w400,
                                height: 1.05,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                Flexible(
                                  child: Text(
                                    role == ProfileRole.parent
                                        ? name
                                        : '$name👋',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: FontSize.small,
                                      fontWeight: FontWeight.w600,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                                if (canSwitchProfile)
                                  AnimatedRotation(
                                    turns: isProfileMenuOpen ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 180),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 12,
                                      color: colors.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (role == ProfileRole.parent) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: DashboardParentFireBadge(count: parentStreakCount),
              ),
            ],
            DashboardNotificationButton(
              onTap: onNotificationTap,
              hasUnreadNotifications: hasUnreadNotifications,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardParentFireBadge extends StatelessWidget {
  const DashboardParentFireBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 30,
      constraints: const BoxConstraints(minWidth: 45),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: colors.accent,
            size: 20,
          ),
          Text(
            '$count',
            style: TextStyle(
              color: colors.accent,
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardProfileAvatar extends StatelessWidget {
  const DashboardProfileAvatar({
    super.key,
    required this.size,
    this.avatarKey,
    this.avatarUrl,
    this.borderColor,
    this.showStatus = true,
  });

  final double size;
  final String? avatarKey;
  final String? avatarUrl;
  final Color? borderColor;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.brand.withValues(alpha: 0.05),
                spreadRadius: size * 0.08,
              ),
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ProfileAvatarImage(
            size: size,
            avatarKey: avatarKey,
            avatarUrl: avatarUrl,
            borderColor: borderColor?.withValues(alpha: 0.9),
            borderWidth: borderColor == null ? 0 : 1.5,
          ),
        ),
        if (showStatus)
          Positioned(
            right: -size * 0.05,
            bottom: -size * 0.05,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.elevatedSurface,
                  width: size * 0.05,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class DashboardNotificationButton extends StatelessWidget {
  const DashboardNotificationButton({
    super.key,
    required this.onTap,
    this.hasUnreadNotifications = false,
  });

  final VoidCallback onTap;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: colors.elevatedSurface,
      shadowColor: colors.shadow.withValues(alpha: 0.24),
      elevation: 2,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: SvgPicture.asset(
                  studentHomeBellAsset,
                  width: 12,
                  height: 15,
                ),
              ),
              if (hasUnreadNotifications)
                Positioned(
                  top: 2,
                  right: 2,
                  child: NotificationUnreadDot(
                    borderColor: colors.elevatedSurface,
                    size: 8,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
