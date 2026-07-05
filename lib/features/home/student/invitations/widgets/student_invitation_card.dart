part of '../../../home_screen.dart';

class _StudentInvitationCard extends StatelessWidget {
  const _StudentInvitationCard({
    required this.invitation,
    required this.isProcessing,
    this.compactActions = false,
    required this.onAccept,
    required this.onReject,
  });

  final ClassroomInvitation invitation;
  final bool isProcessing;
  final bool compactActions;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final classroom = invitation.classroom;
    final title = classroom?.name?.trim().isNotEmpty == true
        ? classroom!.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final inviterName = invitation.inviterName?.trim();
    final subtitle = inviterName != null && inviterName.isNotEmpty
        ? context.formatText(AppKeys.studentInviteSubtitle, {
            'name': inviterName,
          })
        : context.getText(AppKeys.studentInviteSubtitleFallback);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: compactActions
          ? _buildCompact(context, title, subtitle)
          : Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      studentHomeInviteAsset,
                      width: 36,
                      height: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF181C1E),
                              fontSize: FontSize.normal,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF444650),
                              fontSize: FontSize.caption,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                if (isProcessing)
                  const SizedBox(
                    height: 27,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: homeTeal,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _StudentInviteButton(
                          label: context.getText(AppKeys.accept),
                          color: const Color(0xFF38898C),
                          onTap: onAccept,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StudentInviteButton(
                          label: context.getText(AppKeys.reject),
                          color: const Color(0xFFF37850),
                          onTap: onReject,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _buildCompact(BuildContext context, String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF001741),
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF001741).withValues(alpha: 0.7),
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (isProcessing)
          const SizedBox(
            width: 56,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: homeTeal,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StudentInviteIconButton(
                asset: studentParentHomeAcceptIconAsset,
                label: context.getText(AppKeys.accept),
                onTap: onAccept,
              ),
              const SizedBox(width: 8),
              _StudentInviteIconButton(
                asset: studentParentHomeRejectIconAsset,
                label: context.getText(AppKeys.reject),
                onTap: onReject,
              ),
            ],
          ),
      ],
    );
  }
}
