part of '../home_screen.dart';

extension _StudentHomeModeTwoView on _StudentHomeContentState {
  Widget _buildStudentModeTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _studentModeEntrance(
          order: 0,
          child: _ParentImageAction(
            asset: _parentHomeAfterReviewBanner,
            height: 214,
            onTap: widget.onOpenReviewTab,
          ),
        ),
        const SizedBox(height: 8),
        _studentModeEntrance(
          order: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _ParentImageAction(
                      asset: _parentHomeRace,
                      height: 83,
                      onTap: widget.onOpenReviewTab,
                    ),
                    const SizedBox(height: 7),
                    _ParentImageAction(
                      asset: _parentHomeShop,
                      height: 83,
                      onTap: widget.onOpenReviewTab,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ParentImageAction(
                  asset: _parentHomeClassroom,
                  height: 173,
                  onTap: widget.onOpenClassroomTab,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _studentModeEntrance(
          order: 2,
          markOnEnd: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StudentInvitationsSection(
                invitations: _invitations,
                processingClassroomIds: _processingInvitationClassIds,
                showJoinClassroom: widget.activeRole == ProfileRole.student &&
                    _classrooms.isEmpty,
                onJoinClassroom: widget.onOpenClassroomTab,
                onViewAll: _openAllInvitations,
                onAccept: (invitation) => _handleInvitation(
                  invitation,
                  accept: true,
                ),
                onReject: (invitation) => _handleInvitation(
                  invitation,
                  accept: false,
                ),
              ),
              const SizedBox(height: 20),
              const _HomeTeacherMessages(),
            ],
          ),
        ),
      ],
    );
  }
}
