part of '../home_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({
    super.key,
    required this.args,
  });

  final HomeDashboardArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return _StudentHomeContent(
        padding: EdgeInsets.fromLTRB(
          14 * args.scale,
          args.headerHeight,
          14 * args.scale,
          args.bottomPadding,
        ),
        scale: args.scale,
        user: args.user,
        profiles: args.profiles,
        activeProfile: args.activeProfile,
        activeRole: ProfileRole.student,
        isActive: args.isActive,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        classroomService: args.classroomService,
        assignmentService: args.assignmentService,
        quizService: args.quizService,
        onOpenClassroomTab: args.onOpenClassroomTab,
        onOpenReviewTab: args.onOpenReviewTab,
        onRefreshProfiles: args.onRefreshProfiles,
        onActivateProfile: args.onActivateProfile,
        onProfileSaved: args.onProfileSaved,
        parentHomeEntrance: args.parentHomeEntrance,
        activeRefreshTick: args.activeRefreshTick,
      );
    }

    if (args.activeTab == 1) {
      return _StudentClassroomTab(
        bottomPadding: args.bottomPadding,
        scale: args.scale,
        user: args.user,
        activeProfile: args.activeProfile,
        classroomService: args.classroomService,
        isActive: args.isActive,
        activeRefreshTick: args.activeRefreshTick,
      );
    }

    if (args.activeTab == 2) {
      return ReviewTab(
        user: args.user,
        activeProfile: args.activeProfile,
        isParentMode: false,
        profileLoadError: args.profileLoadError,
        onRefreshProfiles: args.onRefreshProfiles,
        onAddProfile: args.onAddProfileFromReview,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
        isActive: args.isActive,
      );
    }

    if (args.activeTab == 3) {
      return HistoryTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      );
    }

    if (args.activeTab == 4) {
      return _dashboardSettings(args);
    }

    return const SizedBox.shrink();
  }
}
