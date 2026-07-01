import 'package:flutter/widgets.dart';

import 'package:numi_flutter/features/classroom/presentation/teacher_classroom_screens.dart';
import 'package:numi_flutter/features/home/helpers/home_dashboard_helpers.dart';
import 'package:numi_flutter/features/home/widgets/home_dashboard_args.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key, required this.args});

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
        onOpenStudyTab: args.onOpenPracticeTab,
        exerciseService: args.assignmentService,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      );
    }

    if (args.activeTab == 1) {
      return TeacherClassroomTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
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
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      );
    }

    if (args.activeTab == 3) {
      return const SizedBox.shrink();
    }

    if (args.activeTab == 4) {
      return dashboardSettings(args);
    }

    return const SizedBox.shrink();
  }
}
