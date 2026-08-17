import 'package:numi/features/profile/helpers/profile_identity_helpers.dart';
import 'package:flutter/material.dart';
import 'package:numi/features/dashboard/helpers/dashboard_tab_builders.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/games/presentation/games_tab.dart';
import 'package:numi/features/quiz/presentation/tabs/parent_assessment_tab.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';
import 'package:numi/features/classroom/presentation/tabs/parent_room_tab.dart';

class ParentTabHost extends StatelessWidget {
  const ParentTabHost({super.key, required this.args});

  final DashboardTabArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return ParentHomeContent(
        user: args.user,
        profiles: args.profiles,
        activeProfile: args.activeProfile,
        isActive: args.isActive,
        activeRefreshTick: args.activeRefreshTick,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        quizService: args.quizService,
        onRefreshProfiles: args.onRefreshProfiles,
        onActivateProfile: args.onActivateProfile,
        onProfileSaved: args.onProfileSaved,
        onOpenProfileMenu: args.onOpenProfileMenu,
        onOpenClassroomTab: args.onOpenClassroomTab,
        onOpenPracticeTab: args.onOpenPracticeTab,
        onParentAssessmentStateChanged: args.onParentAssessmentStateChanged,
        bottomPadding: args.bottomPadding,
        homeHeader: args.homeHeader,
        showChildProfileDialogOnStart: args.showChildProfileDialogOnStart,
        onChildProfileDialogShown: args.onChildProfileDialogShown,
      );
    }

    if (args.activeTab == 1) {
      return ParentAssessmentTab(
        user: args.user,
        activeProfile: args.activeProfile,
        isActive: args.isActive,
        activeRefreshTick: args.activeRefreshTick,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        quizService: args.quizService,
        bottomPadding: args.bottomPadding,
      );
    }

    if (args.activeTab == 2) {
      return ParentRoomTab(
        user: args.user,
        profiles: args.profiles,
        activeProfile: args.activeProfile,
        isActive: args.isActive,
        activeRefreshTick: args.activeRefreshTick,
        assignmentService: args.assignmentService,
        onRefreshProfiles: args.onRefreshProfiles,
        onActivateProfile: args.onActivateProfile,
        onProfileSaved: args.onProfileSaved,
        onOpenClassroomTab: args.onOpenClassroomTab,
        onOpenProfileMenu: args.onOpenProfileMenu,
        bottomPadding: args.bottomPadding,
      );
    }

    if (args.activeTab == 3) {
      return GamesTab(
        userId: args.user?.id,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        initialGradeId: profileGradeStableId(args.activeProfile),
        initialGradeLabel: args.activeProfile?.grade?.label,
        bottomPadding: args.bottomPadding,
      );
    }

    if (args.activeTab == 4) {
      return buildSettingsTab(args);
    }

    return const SizedBox.shrink();
  }
}
