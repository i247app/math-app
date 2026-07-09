import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

import 'package:numi/features/profile/widgets/profile_avatar_image.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.avatarKey,
    required this.avatarUrl,
    required this.isActive,
    required this.scale,
  });

  final String? avatarKey;
  final String? avatarUrl;
  final bool isActive;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 72 * scale;

    return ProfileAvatarImage(
      size: size,
      avatarKey: avatarKey,
      avatarUrl: avatarUrl,
      borderColor: isActive ? AppColors.tealIcon : const Color(0xFFC8D0CC),
      borderWidth: 4 * scale,
    );
  }
}
