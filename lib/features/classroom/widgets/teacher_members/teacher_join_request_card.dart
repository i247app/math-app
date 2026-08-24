import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_empty_member_text.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_join_request_row.dart';

class TeacherJoinRequestCard extends StatelessWidget {
  const TeacherJoinRequestCard({
    super.key,
    required this.requests,
    required this.processingProfileIds,
    required this.onApprove,
    required this.onReject,
  });
  final List<ClassroomStudent> requests;
  final Set<int> processingProfileIds;
  final ValueChanged<ClassroomStudent> onApprove;
  final ValueChanged<ClassroomStudent> onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return TeacherEmptyMemberText(
        text: context.getText(AppKeys.teacherNoJoinRequests),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < requests.length; index++) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Divider(height: 1, color: Color(0xFFF9FAFB)),
              ),
            Padding(
              padding: EdgeInsets.only(
                bottom: index == requests.length - 1 ? 0 : 16,
              ),
              child: TeacherJoinRequestRow(
                request: requests[index],
                isProcessing: processingProfileIds.contains(
                  requests[index].profileId,
                ),
                onApprove: () => onApprove(requests[index]),
                onReject: () => onReject(requests[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
