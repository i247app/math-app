import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_function_grid.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_member_management_card.dart';

class TeacherClassDetailLowerContent extends StatelessWidget {
  const TeacherClassDetailLowerContent({
    super.key,
    required this.memberCount,
    required this.requestCount,
    required this.onOpenAssignments,
    required this.onOpenAssessments,
    required this.onOpenMembers,
  });
  final int memberCount;
  final int requestCount;
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenAssessments;
  final VoidCallback onOpenMembers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeacherClassDetailMemberManagementCard(
            memberCount: memberCount,
            requestCount: requestCount,
            onTap: onOpenMembers,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 27),
            child: Text(
              context.getText(AppKeys.teacherClassFunctions),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1E3A5F),
                fontSize: FontSize.large,
                fontWeight: FontWeight.w700,
                height: 1.55,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: TeacherClassDetailFunctionGrid(
              onOpenAssignments: onOpenAssignments,
              onOpenAssessments: onOpenAssessments,
            ),
          ),
        ],
      ),
    );
  }
}
