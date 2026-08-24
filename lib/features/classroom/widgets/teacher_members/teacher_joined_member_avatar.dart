import 'package:flutter/material.dart';

import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_classroom_member_avatar.dart';

class TeacherJoinedMemberAvatar extends StatelessWidget {
  const TeacherJoinedMemberAvatar({super.key, required this.member});

  final ClassroomStudent member;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          Positioned.fill(
            child: TeacherClassroomMemberAvatar(member: member, size: 56),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
