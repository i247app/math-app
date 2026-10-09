import 'package:flutter/material.dart';

import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/exam/data/exam_service.dart';

/// Shared dashboard inputs; the host only changes activation for each tab.
class DashboardTabArgs {
  const DashboardTabArgs({
    required this.activeTab,
    required this.isActive,
    required this.activeRefreshTick,
    required this.session,
    required this.services,
    required this.actions,
    required this.presentation,
  });
  final DashboardTabId activeTab;
  final bool isActive;
  final int activeRefreshTick;
  final DashboardSessionData session;
  final DashboardTabServices services;
  final DashboardTabActions actions;
  final DashboardTabPresentation presentation;

  DashboardTabArgs forActivation({
    required DashboardTabId tab,
    required bool isActive,
    required int refreshTick,
  }) => DashboardTabArgs(
    activeTab: tab,
    isActive: isActive,
    activeRefreshTick: refreshTick,
    session: session,
    services: services,
    actions: actions,
    presentation: presentation,
  );

  EdgeInsets get contentPadding => EdgeInsets.only(
    left: 24,
    right: 24,
    top: activeTab == DashboardTabId.home ? 0 : 24,
    bottom: presentation.bottomPadding,
  );
}

class DashboardSessionData {
  const DashboardSessionData({
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.initialGrades,
  });
  final LoginUser? user;
  final List<UserProfile> profiles;
  final UserProfile? activeProfile;
  final String? profileLoadError;
  final List<GradeModel> initialGrades;
}

class DashboardTabServices {
  const DashboardTabServices({
    required this.gradeService,
    required this.classroomService,
    required this.assignmentService,
    required this.examService,
  });
  final GradeService gradeService;
  final ClassroomService classroomService;
  final ClassroomExerciseService assignmentService;
  final ExamService examService;
}

class DashboardTabActions {
  const DashboardTabActions({
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.onLogout,
    required this.onProfileSaved,
    required this.onCompleteTeacherProfile,
    required this.onOpenClassroomTab,
    required this.onOpenGamesTab,
    required this.onOpenExercisesTab,
    required this.onOpenProfileMenu,
    required this.onParentAssessmentStateChanged,
    required this.onNotificationTap,
    this.onChildProfileDialogShown,
  });
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(UserProfile profile) onActivateProfile;
  final VoidCallback onLogout;
  final VoidCallback onProfileSaved;
  final Future<void> Function() onCompleteTeacherProfile;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenGamesTab;
  final VoidCallback onOpenExercisesTab;
  final VoidCallback onOpenProfileMenu;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final VoidCallback onNotificationTap;
  final VoidCallback? onChildProfileDialogShown;
}

class DashboardTabPresentation {
  const DashboardTabPresentation({
    required this.openAddProfileRequestId,
    required this.bottomPadding,
    required this.hasUnreadNotifications,
    required this.showChildProfileDialogOnStart,
    this.homeHeader,
  });
  final int openAddProfileRequestId;
  final double bottomPadding;
  final bool hasUnreadNotifications;
  final bool showChildProfileDialogOnStart;
  final Widget? homeHeader;
}
