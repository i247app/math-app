import 'package:flutter/material.dart';

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
    required this.scale,
    required this.request,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  final double scale;
  final ClassroomStudent request;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final name = classroomMemberName(context, request);
    return Row(
      children: [
        TeacherClassroomMemberAvatar(member: request, size: 40 * scale),
        SizedBox(width: 12 * scale),
        Expanded(
          child: TeacherMemberTextBlock(
            name: name,
            status: context.getText(AppKeys.teacherPendingApproval),
            nameFontSize: 16 * scale,
            statusFontSize: 12 * scale,
            nameColor: const Color(0xFF1E3A5F),
            statusColor: AppColors.textCoolMuted,
          ),
        ),
        SizedBox(width: 10 * scale),
        if (isProcessing)
          SizedBox(
            width: 53 * scale,
            child: Center(
              child: SizedBox(
                width: 18 * scale,
                height: 18 * scale,
                child: const CircularProgressIndicator(
                  color: AppColors.teal520,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else ...[
          TeacherRequestActionIcon(
            asset: 'assets/images/teacher_member_accept.png',
            size: 25 * scale,
            onTap: request.profileId == null ? null : onApprove,
          ),
          SizedBox(width: 5 * scale),
          TeacherRequestActionIcon(
            asset: 'assets/images/teacher_member_reject.png',
            size: 23 * scale,
            onTap: request.profileId == null ? null : onReject,
          ),
        ],
      ],
    );
  }
}
