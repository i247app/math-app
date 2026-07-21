import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_classroom_member_avatar.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_helpers.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_text_block.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_request_action_icon.dart';

class TeacherJoinRequestRow extends StatelessWidget {
  const TeacherJoinRequestRow({
    super.key,
    required this.request,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });
  final ClassroomStudent request;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final name = classroomMemberName(context, request);
    return Row(
      children: [
        TeacherClassroomMemberAvatar(member: request, size: 40),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 10),
            child: TeacherMemberTextBlock(
              name: name,
              status: context.getText(AppKeys.teacherPendingApproval),
              nameFontSize: FontSize.normal,
              statusFontSize: FontSize.xxs,
              nameColor: const Color(0xFF1E3A5F),
              statusColor: AppColors.textCoolMuted,
            ),
          ),
        ),
        if (isProcessing)
          const SizedBox(
            width: 53,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.teal520,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else
          Row(
            spacing: 5,
            mainAxisSize: MainAxisSize.min,
            children: [
              TeacherRequestActionIcon(
                asset: 'assets/images/teacher_member_accept.png',
                size: 25,
                onTap: request.profileId == null ? null : onApprove,
              ),
              TeacherRequestActionIcon(
                asset: 'assets/images/teacher_member_reject.png',
                size: 23,
                onTap: request.profileId == null ? null : onReject,
              ),
            ],
          ),
      ],
    );
  }
}
