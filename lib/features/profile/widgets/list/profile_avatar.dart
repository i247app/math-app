import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/profile_avatar_image.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.avatarKey,
    required this.avatarUrl,
    required this.isActive,
  });

  final String? avatarKey;
  final String? avatarUrl;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ProfileAvatarImage(
      size: size,
      avatarKey: avatarKey,
      avatarUrl: avatarUrl,
      backgroundColor: isDark
          ? colors.elevatedSurface
          : const Color(0xFFE2EAED),
      foregroundColor: isDark ? colors.brandStrong : const Color(0xFF2A7D75),
      borderColor: isDark
          ? (isActive ? colors.brandStrong : colors.border)
          : (isActive ? AppColors.tealIcon : const Color(0xFFC8D0CC)),
      borderWidth: 4,
    );
  }
}
