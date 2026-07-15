import 'package:flutter/material.dart';

import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/profile/widgets/profile_avatar_image.dart';

class TeacherClassroomMemberAvatar extends StatelessWidget {
  const TeacherClassroomMemberAvatar({
    super.key,
    required this.member,
    required this.size,
  });

  final ClassroomStudent member;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarImage(
      size: size,
      avatarKey: member.avatarKey,
      avatarUrl: member.avatarUrl,
    );
  }
}
