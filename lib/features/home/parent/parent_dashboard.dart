part of '../home_screen.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({
    super.key,
    required this.args,
  });

  final HomeDashboardArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return _StudentHomeContent(
        padding: args.contentPadding,
        scale: args.scale,
        user: args.user,
        profiles: args.profiles,
        activeProfile: args.activeProfile,
        activeRole: ProfileRole.parent,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        classroomService: args.classroomService,
        onOpenClassroomTab: args.onOpenClassroomTab,
        onOpenReviewTab: args.onOpenReviewTab,
        onRefreshProfiles: args.onRefreshProfiles,
        onActivateProfile: args.onActivateProfile,
        onProfileSaved: args.onProfileSaved,
        parentHomeEntrance: args.parentHomeEntrance,
      );
    }

    if (args.activeTab == 1) {
      return ReviewTab(
        user: args.user,
        activeProfile: args.activeProfile,
        isParentMode: true,
        profileLoadError: args.profileLoadError,
        onRefreshProfiles: args.onRefreshProfiles,
        onAddProfile: args.onAddProfileFromReview,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
      );
    }

    if (args.activeTab == 2) {
      return HistoryTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
      );
    }

    if (args.activeTab == 3) {
      return _dashboardSettings(args);
    }

    return const SizedBox.shrink();
  }
}
