import 'package:flutter/material.dart';

import 'package:numi/features/profile/widgets/profile_avatar_image.dart';
import 'package:numi/features/settings/widgets/account/settings_round_icon_button.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.avatarUrl,
    required this.avatarPath,
    required this.isEditing,
    required this.isPickingAvatar,
    required this.onCameraTap,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final bool isEditing;
  final bool isPickingAvatar;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    const size = 126.0;

    return Center(
      child: SizedBox(
        width: 156,
        height: 156,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8601C).withValues(alpha: 0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ProfileAvatarImage(
                size: size,
                avatarPath: avatarPath,
                avatarUrl: avatarUrl,
                borderColor: const Color(0xFFFF7451),
                borderWidth: 3.8,
                padding: const EdgeInsets.all(6),
              ),
            ),
            if (isPickingAvatar)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            if (isEditing)
              Positioned(
                right: 16,
                bottom: 20,
                child: SettingsRoundIconButton(
                  icon: Icons.photo_camera_outlined,
                  size: 38,
                  iconSize: 20,
                  borderColor: const Color(0xFFC21873),
                  foregroundColor: const Color(0xFF253228),
                  backgroundColor: Colors.white,
                  onTap: onCameraTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
