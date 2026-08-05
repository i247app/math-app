import 'package:flutter/material.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/dashboard/helpers/dashboard_tab_builders.dart';
import 'package:numi/features/home/student/home/student_home_tab.dart';
import 'package:numi/features/classroom/presentation/tabs/student_classroom_tab.dart';
import 'package:numi/features/practice/practice_tab.dart';
import 'package:numi/features/quiz/presentation/tabs/history_tab.dart';

class StudentTabHost extends StatelessWidget {
  const StudentTabHost({super.key, required this.args});

  final DashboardTabArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return StudentHomeContent(
        padding: EdgeInsets.fromLTRB(14, 14, 14, args.bottomPadding),
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
        onOpenHistoryTab: args.onOpenHistoryTab,
        onRefreshProfiles: args.onRefreshProfiles,
        onActivateProfile: args.onActivateProfile,
        onProfileSaved: args.onProfileSaved,
        parentHomeEntrance: args.parentHomeEntrance,
        activeRefreshTick: args.activeRefreshTick,
        header: args.homeHeader,
      );
    }

    if (args.activeTab == 1) {
      return StudentClassroomTab(
        bottomPadding: args.bottomPadding,
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
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      );
    }

    if (args.activeTab == 3) {
      return HistoryTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        classroomService: args.classroomService,
        assignmentService: args.assignmentService,
        quizService: args.quizService,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      );
    }

    if (args.activeTab == 4) {
      return buildSettingsTab(args);
    }

    return const SizedBox.shrink();
  }
}
