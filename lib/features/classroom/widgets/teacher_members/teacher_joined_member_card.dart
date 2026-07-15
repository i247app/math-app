import 'package:flutter/material.dart';

import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_joined_member_avatar.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_helpers.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_text_block.dart';

class TeacherJoinedMemberCard extends StatelessWidget {
  const TeacherJoinedMemberCard({
    super.key,
    required this.scale,
    required this.member,
  });

  final double scale;
  final ClassroomStudent member;

  @override
  Widget build(BuildContext context) {
    final name = classroomMemberName(context, member);
    final status = classroomMemberStatus(context, member);
    return Container(
      constraints: BoxConstraints(minHeight: 82 * scale),
      padding: EdgeInsets.all(13 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x4DC4C6D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 1 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          TeacherJoinedMemberAvatar(member: member, scale: scale),
          SizedBox(width: 24 * scale),
          Expanded(
            child: TeacherMemberTextBlock(
              name: name,
              status: status,
              nameFontSize: 14 * scale,
              statusFontSize: 12 * scale,
              nameColor: const Color(0xFF181C1E),
              statusColor: const Color(0xFF747781),
              letterSpacing: 0.7 * scale,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: const Color(0xFFC4C6D2),
              size: 20 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
