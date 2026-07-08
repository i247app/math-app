part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherJoinRequestRow extends StatelessWidget {
  const _TeacherJoinRequestRow({
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
    final name = _classroomMemberName(context, request);
    return Row(
      children: [
        _TeacherClassroomMemberAvatar(member: request, size: 40 * scale),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _TeacherMemberTextBlock(
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
          _TeacherRequestActionIcon(
            asset: 'assets/images/teacher_member_accept.png',
            size: 25 * scale,
            onTap: request.profileId == null ? null : onApprove,
          ),
          SizedBox(width: 5 * scale),
          _TeacherRequestActionIcon(
            asset: 'assets/images/teacher_member_reject.png',
            size: 23 * scale,
            onTap: request.profileId == null ? null : onReject,
          ),
        ],
      ],
    );
  }
}
