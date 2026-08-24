import 'package:flutter/widgets.dart';

import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/widgets/profile_avatar_image.dart';

class ParentProfileAvatar extends StatelessWidget {
  const ParentProfileAvatar({super.key, required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    const size = 80.0;

    return ProfileAvatarImage(
      size: size,
      avatarKey: profile.avatarKey,
      avatarUrl: profile.avatarUrl,
      backgroundColor: const Color(0xFFE6F5F5),
      foregroundColor: const Color(0xFF008080),
      borderColor: const Color(0xFF008080),
      borderWidth: 3,
    );
  }
}
