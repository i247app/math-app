import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/shared/widgets/profile_avatar_image.dart';

class SettingsAvatar extends StatelessWidget {
  const SettingsAvatar({
    super.key,
    required this.activeProfile,
    required this.fallbackAvatarUrl,
    required this.fallbackAvatarPath,
    required this.onSwitchTap,
  });

  final StudentProfile? activeProfile;
  final String? fallbackAvatarUrl;
  final String? fallbackAvatarPath;
  final VoidCallback onSwitchTap;

  @override
  Widget build(BuildContext context) {
    const size = 92.0;

    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8601C).withValues(alpha: 0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ProfileAvatarImage(
                size: size,
                avatarKey: activeProfile?.avatarKey,
                avatarUrl: activeProfile?.avatarUrl ?? fallbackAvatarUrl,
                avatarPath: activeProfile == null ? fallbackAvatarPath : null,
                borderColor: const Color(0xFFE8601C),
                borderWidth: 3.2,
                padding: const EdgeInsets.all(4),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 14,
            child: Semantics(
              button: true,
              label: context.getText(AppKeys.profileMenuTitle),
              child: Material(
                color: AppColors.tealIcon,
                elevation: 5,
                shadowColor: AppColors.tealIcon.withValues(alpha: 0.22),
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 2.5),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSwitchTap,
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
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
