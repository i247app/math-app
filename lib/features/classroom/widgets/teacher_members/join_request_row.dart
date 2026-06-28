part of '../../presentation/teacher_classroom_screens.dart';

class _JoinRequestRow extends StatelessWidget {
  const _JoinRequestRow({
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
        _ClassroomMemberAvatar(
          member: request,
          size: 40 * scale,
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _MemberTextBlock(
            name: name,
            status: context.getText(AppKeys.teacherPendingApproval),
            nameFontSize: 16 * scale,
            statusFontSize: 12 * scale,
            nameColor: const Color(0xFF1E3A5F),
            statusColor: _teacherMuted,
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
                  color: _teacherTeal,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else ...[
          _RequestActionIcon(
            asset: 'assets/images/teacher_member_accept.png',
            size: 25 * scale,
            onTap: request.profileId == null ? null : onApprove,
          ),
          SizedBox(width: 5 * scale),
          _RequestActionIcon(
            asset: 'assets/images/teacher_member_reject.png',
            size: 23 * scale,
            onTap: request.profileId == null ? null : onReject,
          ),
        ],
      ],
    );
  }
}
