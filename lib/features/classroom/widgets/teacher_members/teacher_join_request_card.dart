import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_empty_member_text.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_join_request_row.dart';

class TeacherJoinRequestCard extends StatelessWidget {
  const TeacherJoinRequestCard({
    super.key,
    required this.scale,
    required this.requests,
    required this.processingProfileIds,
    required this.onApprove,
    required this.onReject,
  });

  final double scale;
  final List<ClassroomStudent> requests;
  final Set<int> processingProfileIds;
  final ValueChanged<ClassroomStudent> onApprove;
  final ValueChanged<ClassroomStudent> onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return TeacherEmptyMemberText(
        scale: scale,
        text: context.getText(AppKeys.teacherNoJoinRequests),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 25 * scale,
        vertical: 16 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < requests.length; index++) ...[
            if (index > 0)
              Padding(
                padding: EdgeInsets.only(bottom: 10 * scale),
                child: const Divider(height: 1, color: Color(0xFFF9FAFB)),
              ),
            TeacherJoinRequestRow(
              scale: scale,
              request: requests[index],
              isProcessing: processingProfileIds.contains(
                requests[index].profileId,
              ),
              onApprove: () => onApprove(requests[index]),
              onReject: () => onReject(requests[index]),
            ),
            if (index != requests.length - 1) SizedBox(height: 16 * scale),
          ],
        ],
      ),
    );
  }
}
