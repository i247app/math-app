import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/shared/widgets/profile_avatar_image.dart';

class ParentProfileAvatar extends StatelessWidget {
  const ParentProfileAvatar({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    const size = 80.0;
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ProfileAvatarImage(
      size: size,
      avatarKey: profile.avatarKey,
      avatarUrl: profile.avatarUrl,
      backgroundColor: isDark
          ? colors.elevatedSurface
          : const Color(0xFFE6F5F5),
      foregroundColor: isDark ? colors.brandStrong : const Color(0xFF008080),
      borderColor: isDark ? colors.brandStrong : const Color(0xFF008080),
      borderWidth: 3,
    );
  }
}
