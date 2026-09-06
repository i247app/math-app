part of '../role_tab_host.dart';

extension _RoleTabBuilder on RoleTabHostState {
  Widget _buildTab(BuildContext context, int tab) {
    final args = DashboardTabArgs(
      activeTab: tab,
      isActive: tab == widget.activeTab,
      user: widget.user,
      profiles: widget.profiles,
      activeProfile: widget.activeProfile,
      profileLoadError: widget.profileLoadError,
      onRefreshProfiles: widget.onRefreshProfiles,
      onActivateProfile: widget.onActivateProfile,
      initialGrades: widget.initialGrades,
      gradeService: widget.gradeService,
      classroomService: widget.classroomService,
      assignmentService: widget.assignmentService,
      quizService: widget.quizService,
      onLogout: widget.onLogout,
      onAddProfileFromPractice: widget.onAddProfileFromPractice,
      onProfileSaved: widget.onProfileSaved,
      openAddProfileRequestId: widget.openAddProfileRequestId,
      onCompleteTeacherProfile: widget.onCompleteTeacherProfile,
      onOpenClassroomTab: widget.onOpenClassroomTab,
      onOpenPracticeTab: widget.onOpenPracticeTab,
      onOpenProfileMenu: widget.onOpenProfileMenu,
      onParentAssessmentStateChanged: widget.onParentAssessmentStateChanged,
      activeRefreshTick: _activationTicks[tab] ?? 0,
      bottomPadding: widget.bottomPadding,
      hasUnreadNotifications: widget.hasUnreadNotifications,
      onNotificationTap: widget.onNotificationTap,
      showChildProfileDialogOnStart: widget.showChildProfileDialogOnStart,
      onChildProfileDialogShown: widget.onChildProfileDialogShown,
      homeHeader: tab == 0 ? widget.homeHeader : null,
    );

    return widget.tabFactory.buildTab(
      context: context,
      role: widget.activeRole,
      args: args,
    );
  }
}
