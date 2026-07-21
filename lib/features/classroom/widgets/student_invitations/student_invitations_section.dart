import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/shared/widgets/app_section_header.dart';
import 'package:numi/features/classroom/widgets/student_invitations/student_invitation_card.dart';
import 'package:numi/features/classroom/widgets/student_invitations/student_join_class_cta.dart';

class StudentInvitationsSection extends StatelessWidget {
  const StudentInvitationsSection({
    super.key,
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
          if (showInvitationPreview)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSectionHeader(
                    title: context.getText(AppKeys.studentClassInvitations),
                    actionLabel: context.formatText(
                      AppKeys.studentViewAllInvitations,
                      {'count': invitations.length},
                    ),
                    onAction: onViewAll,
                  ),
                  StudentInvitationCard(
                    invitation: invitation,
                    isProcessing: processingClassroomIds.contains(
                      invitation.stableClassroomId,
                    ),
                    compactActions: true,
                    onAccept: () => onAccept(invitation),
                    onReject: () => onReject(invitation),
                  ),
                ],
              ),
            ),
          if (showJoinClassroom) StudentJoinClassCta(onTap: onJoinClassroom),
        ],
      ),
    );
  }
}
