import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_function_grid.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_member_management_card.dart';

class TeacherClassDetailLowerContent extends StatelessWidget {
  const TeacherClassDetailLowerContent({
    super.key,
    required this.scale,
    required this.memberCount,
    required this.requestCount,
    required this.onOpenAssignments,
    required this.onOpenAssessments,
    required this.onOpenMembers,
  });

  final double scale;
  final int memberCount;
  final int requestCount;
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenAssessments;
  final VoidCallback onOpenMembers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeacherClassDetailMemberManagementCard(
            scale: scale,
            memberCount: memberCount,
            requestCount: requestCount,
            onTap: onOpenMembers,
          ),
          SizedBox(height: 27 * scale),
          Text(
            context.getText(AppKeys.teacherClassFunctions),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: const Color(0xFF1E3A5F),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              height: 1.55,
            ),
          ),
          SizedBox(height: 7 * scale),
          TeacherClassDetailFunctionGrid(
            scale: scale,
            onOpenAssignments: onOpenAssignments,
            onOpenAssessments: onOpenAssessments,
          ),
        ],
      ),
    );
  }
}
