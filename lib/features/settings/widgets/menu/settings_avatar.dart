import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/profile/widgets/profile_avatar_image.dart';
import 'package:numi_flutter/features/settings/settings_style.dart';

class SettingsAvatar extends StatelessWidget {
  const SettingsAvatar({
    super.key,
    required this.activeProfile,
    required this.fallbackAvatarUrl,
    required this.fallbackAvatarPath,
    required this.scale,
    required this.onSwitchTap,
  });

  final StudentProfile? activeProfile;
  final String? fallbackAvatarUrl;
  final String? fallbackAvatarPath;
  final double scale;
  final VoidCallback onSwitchTap;

  @override
  Widget build(BuildContext context) {
    final size = 92 * scale;

    return SizedBox(
      width: size + 20 * scale,
      height: size + 20 * scale,
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
                    blurRadius: 14 * scale,
                    offset: Offset(0, 5 * scale),
                  ),
                ],
              ),
              child: ProfileAvatarImage(
                size: size,
                avatarKey: activeProfile?.avatarKey,
                avatarUrl: activeProfile?.avatarUrl ?? fallbackAvatarUrl,
                avatarPath: activeProfile == null ? fallbackAvatarPath : null,
                borderColor: const Color(0xFFE8601C),
                borderWidth: 3.2 * scale,
                padding: EdgeInsets.all(4 * scale),
              ),
            ),
          ),
          Positioned(
            right: 8 * scale,
            bottom: 14 * scale,
            child: Semantics(
              button: true,
              label: context.getText(AppKeys.profileMenuTitle),
              child: Material(
                color: settingsTeal,
                elevation: 5,
                shadowColor: settingsTeal.withValues(alpha: 0.22),
                shape: CircleBorder(
                  side: BorderSide(color: Colors.white, width: 2.5 * scale),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSwitchTap,
                  child: SizedBox(
                    width: 30 * scale,
                    height: 30 * scale,
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 18 * scale,
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
