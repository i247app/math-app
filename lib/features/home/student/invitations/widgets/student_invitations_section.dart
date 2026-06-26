part of '../../../home_screen.dart';

// ignore: unused_element
class _StudentInvitationsSection extends StatelessWidget {
  const _StudentInvitationsSection({
    required this.invitations,
    required this.processingClassroomIds,
    required this.showJoinClassroom,
    required this.onJoinClassroom,
    required this.onViewAll,
    required this.onAccept,
    required this.onReject,
  });

  final List<ClassroomInvitation> invitations;
  final Set<int> processingClassroomIds;
  final bool showJoinClassroom;
  final VoidCallback onJoinClassroom;
  final VoidCallback onViewAll;
  final ValueChanged<ClassroomInvitation> onAccept;
  final ValueChanged<ClassroomInvitation> onReject;

  @override
  Widget build(BuildContext context) {
    final invitation = invitations.isNotEmpty ? invitations.first : null;
    final showInvitationPreview = invitation != null;
    if (!showInvitationPreview && !showJoinClassroom) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showInvitationPreview) ...[
            _StudentSectionHeader(
              title: context.getText(AppKeys.studentClassInvitations),
              actionLabel: context.formatText(
                AppKeys.studentViewAllInvitations,
                {'count': invitations.length},
              ),
              onAction: onViewAll,
            ),
            const SizedBox(height: 10),
            _StudentInvitationCard(
              invitation: invitation,
              isProcessing: processingClassroomIds.contains(
                invitation.stableClassroomId,
              ),
              compactActions: true,
              onAccept: () => onAccept(invitation),
              onReject: () => onReject(invitation),
            ),
            const SizedBox(height: 6),
          ],
          if (showJoinClassroom) _StudentJoinClassCta(onTap: onJoinClassroom),
        ],
      ),
    );
  }
}
