import 'package:flutter/material.dart';
import 'package:numi_flutter/features/profile/models/profile_role.dart';
import 'package:numi_flutter/features/home/widgets/home_dashboard_args.dart';
import 'package:numi_flutter/features/home/helpers/home_dashboard_helpers.dart';
import 'package:numi_flutter/features/home/student/home/student_home_tab.dart';
import 'package:numi_flutter/features/home/student/classroom/student_classroom_tab.dart';
import 'package:numi_flutter/features/practice/practice_tab.dart';
import 'package:numi_flutter/features/quiz/history_tab.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key, required this.args});

  final HomeDashboardArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return StudentHomeContent(
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
        onOpenPracticeTab: args.onOpenPracticeTab,
        onRefreshProfiles: args.onRefreshProfiles,
        onActivateProfile: args.onActivateProfile,
        onProfileSaved: args.onProfileSaved,
        parentHomeEntrance: args.parentHomeEntrance,
        activeRefreshTick: args.activeRefreshTick,
      );
    }

    if (args.activeTab == 1) {
      return StudentClassroomTab(
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
      return PracticeTab(
        user: args.user,
        activeProfile: args.activeProfile,
        isParentMode: false,
        profileLoadError: args.profileLoadError,
        onRefreshProfiles: args.onRefreshProfiles,
        onAddProfile: args.onAddProfileFromPractice,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      );
    }

    if (args.activeTab == 3) {
      return HistoryTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
        classroomService: args.classroomService,
        assignmentService: args.assignmentService,
        quizService: args.quizService,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      );
    }

    if (args.activeTab == 4) {
      return dashboardSettings(args);
    }

    return const SizedBox.shrink();
  }
}