part of '../teacher_home_tab.dart';

extension _TeacherHomeSections on _TeacherRoleTabState {
  Widget _buildClassroomSection({required bool isProfileComplete}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (_isInitialHomeLoading)
          const TeacherAppSectionHeaderSkeleton()
        else
          TeacherClassSectionHeader(
            showAddButton: isProfileComplete,
            onAdd: _handleClassCreateAction,
            onViewAll: widget.onOpenClassroomTab,
          ),
        if (_isInitialHomeLoading)
          const TeacherLoadingPanel()
        else if (_error != null && _classrooms.isEmpty)
          AppRetryPanel(message: _error!, onRetry: _refreshClassrooms)
        else if (_classrooms.isEmpty)
          TeacherEmptyAssignmentsPanel(
            message: context.getText(AppKeys.teacherEmptyClassroomList),
          )
        else
          Column(
            children: [
              TeacherClassCarousel(
                classrooms: _classrooms,
                onOpen: _openClassDetail,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRecentAssignmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (_isInitialAssignmentsLoading)
          const TeacherAppSectionHeaderSkeleton()
        else
          AppSectionHeader(
            title: context.getText(AppKeys.teacherRecentlyAssigned),
            actionLabel: context.getText(AppKeys.viewAll),
            actionIcon: Icons.chevron_right_rounded,
            onAction: widget.onOpenStudyTab,
            titleStyle: TextStyle(
              color: context.themeColors.textPrimary,
              fontSize: FontSize.xl,
              fontWeight: FontWeight.w600,
            ),
            actionStyle: TextStyle(
              color: context.themeColors.info,
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w800,
            ),
          ),
        if (_isInitialAssignmentsLoading)
          const TeacherAssignmentsLoadingPanel()
        else if (_recentAssignments.isEmpty)
          TeacherEmptyAssignmentsPanel(
            message: context.getText(AppKeys.teacherNoAssignments),
          )
        else ...[
          TeacherRecentAssignmentCarousel(
            assignments: _recentAssignments,
            onOpen: _openAssignmentDetail,
          ),
        ],
      ],
    );
  }
}
