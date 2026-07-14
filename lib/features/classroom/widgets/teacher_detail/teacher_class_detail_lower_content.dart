part of 'package:numi/features/classroom/presentation/screens/teacher_classroom_screens.dart';

class _TeacherClassDetailLowerContent extends StatelessWidget {
  const _TeacherClassDetailLowerContent({
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
          _TeacherClassDetailMemberManagementCard(
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
          _TeacherClassDetailFunctionGrid(
            scale: scale,
            onOpenAssignments: onOpenAssignments,
            onOpenAssessments: onOpenAssessments,
          ),
        ],
      ),
    );
  }
}
