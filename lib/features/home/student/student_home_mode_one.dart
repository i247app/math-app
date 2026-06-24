part of '../home_screen.dart';

extension _StudentHomeModeOneView on _StudentHomeContentState {
  Widget _buildStudentModeOne({required bool isLoadingHomeSections}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _studentModeEntrance(
          order: 0,
          child: _ParentModeOneAssessmentBanner(
            onTap: () => _openGradeSelection(quizPurposeAssessment),
          ),
        ),
        const SizedBox(height: 8),
        _studentModeEntrance(
          order: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ParentImageAction(
                  asset: _parentHomeAfterReviewBanner,
                  height: 160,
                  alignment: Alignment.centerLeft,
                  onTap: widget.onOpenReviewTab,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ParentImageAction(
                  asset: _parentHomeClassroom,
                  height: 160,
                  onTap: widget.activeRole == ProfileRole.student
                      ? widget.onOpenClassroomTab
                      : _handleParentClassroomEntry,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (isLoadingHomeSections)
          const _StudentHomeSectionsLoading()
        else
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
                  onJoinClassroom: widget.activeRole == ProfileRole.student
                      ? widget.onOpenClassroomTab
                      : _handleParentClassroomEntry,
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
