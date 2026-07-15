import 'package:flutter/material.dart';

import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_classroom_member_avatar.dart';

class TeacherJoinedMemberAvatar extends StatelessWidget {
  const TeacherJoinedMemberAvatar({
    super.key,
    required this.member,
    required this.scale,
  });

  final ClassroomStudent member;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 * scale,
      height: 56 * scale,
      child: Stack(
        children: [
          Positioned.fill(
            child: TeacherClassroomMemberAvatar(
              member: member,
              size: 56 * scale,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16 * scale,
              height: 16 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
