part of '../home_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({
    super.key,
    required this.args,
  });

  final HomeDashboardArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return TeacherHomeTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
        onCompleteProfile: args.onCompleteTeacherProfile,
        onOpenClassroomTab: args.onOpenClassroomTab,
        exerciseService: args.assignmentService,
      );
    }

    if (args.activeTab == 1) {
      return TeacherClassroomTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
      );
    }

    if (args.activeTab == 2) {
      return TeacherStudyTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
        classroomService: args.classroomService,
        exerciseService: args.assignmentService,
      );
    }

    if (args.activeTab == 3) {
      return const SizedBox.shrink();
    }

    if (args.activeTab == 4) {
      return _dashboardSettings(args);
    }

    return const SizedBox.shrink();
  }
}
