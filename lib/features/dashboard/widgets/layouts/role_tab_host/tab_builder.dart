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
      examService: widget.examService,
      onLogout: widget.onLogout,
      onAddProfileFromGames: widget.onAddProfileFromGames,
      onProfileSaved: widget.onProfileSaved,
      openAddProfileRequestId: widget.openAddProfileRequestId,
      onCompleteTeacherProfile: widget.onCompleteTeacherProfile,
      onOpenClassroomTab: widget.onOpenClassroomTab,
      onOpenGamesTab: widget.onOpenGamesTab,
      onOpenLearningTab: widget.onOpenLearningTab,
      onOpenExercisesTab: widget.onOpenExercisesTab,
      onOpenProfileMenu: widget.onOpenProfileMenu,
      onParentAssessmentStateChanged: widget.onParentAssessmentStateChanged,
      activeRefreshTick: _activationTicks[tab] ?? 0,
      bottomPadding: widget.bottomPadding,
      hasUnreadNotifications: widget.hasUnreadNotifications,
      onNotificationTap: widget.onNotificationTap,
      showChildProfileDialogOnStart: widget.showChildProfileDialogOnStart,
      onChildProfileDialogShown: widget.onChildProfileDialogShown,
      homeHeader: tab == 0 || tab == learningTabIndex
          ? widget.homeHeader
          : null,
    );

    return widget.tabFactory.buildTab(
      context: context,
      role: widget.activeRole,
      args: args,
    );
  }
}
