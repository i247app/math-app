part of '../home_screen.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key, required this.args});

  final HomeDashboardArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return _ParentHomeContent(args: args);
    }

    if (args.activeTab == 1) {
      return ParentAssessmentTab(args: args);
    }

    if (args.activeTab == 2) {
      return ParentRoomTab(args: args);
    }

    if (args.activeTab == 3) {
      return GamesTab(
        userId: args.user?.id,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        initialGradeId: profileGradeId(args.activeProfile),
        initialGradeLabel: args.activeProfile?.grade?.label,
        bottomPadding: args.bottomPadding,
      );
    }

    if (args.activeTab == 4) {
      return dashboardSettings(args);
    }

    return const SizedBox.shrink();
  }
}
