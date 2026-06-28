import 'package:flutter/widgets.dart';

import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/profile/widgets/profile_avatar_image.dart';

class ParentProfileAvatar extends StatelessWidget {
  const ParentProfileAvatar({
    super.key,
    required this.profile,
    required this.scale,
  });

  final StudentProfile profile;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 80 * scale;

    return ProfileAvatarImage(
      size: size,
      avatarKey: profile.avatarKey,
      avatarUrl: profile.avatarUrl,
      backgroundColor: const Color(0xFFE6F5F5),
      foregroundColor: const Color(0xFF008080),
      borderColor: const Color(0xFF008080),
      borderWidth: 3 * scale,
    );
  }
}
