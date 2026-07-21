import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_joined_member_avatar.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_helpers.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_text_block.dart';

class TeacherJoinedMemberCard extends StatelessWidget {
  const TeacherJoinedMemberCard({super.key, required this.member});
  final ClassroomStudent member;

  @override
  Widget build(BuildContext context) {
    final name = classroomMemberName(context, member);
    final status = classroomMemberStatus(context, member);
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x4DC4C6D2)),
        boxShadow: [
          const BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          TeacherJoinedMemberAvatar(member: member),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: TeacherMemberTextBlock(
                name: name,
                status: status,
                nameFontSize: FontSize.small,
                statusFontSize: FontSize.xxs,
                nameColor: const Color(0xFF181C1E),
                statusColor: const Color(0xFF747781),
                letterSpacing: 0.7,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFFC4C6D2),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
