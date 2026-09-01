import 'package:flutter/material.dart';

import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';

class DashboardTabArgs {
  const DashboardTabArgs({
    required this.activeTab,
    required this.isActive,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.initialGrades,
    required this.gradeService,
    required this.classroomService,
    required this.assignmentService,
    required this.quizService,
    required this.onLogout,
    required this.onAddProfileFromPractice,
    required this.onProfileSaved,
    required this.openAddProfileRequestId,
    required this.onCompleteTeacherProfile,
    required this.onOpenClassroomTab,
    required this.onOpenPracticeTab,
    required this.onOpenProfileMenu,
    required this.onParentAssessmentStateChanged,
    required this.activeRefreshTick,
    required this.bottomPadding,
    required this.hasUnreadNotifications,
    required this.onNotificationTap,
    required this.showChildProfileDialogOnStart,
    this.onChildProfileDialogShown,
    this.homeHeader,
  });

  final int activeTab;
  final bool isActive;
  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final ClassroomService classroomService;
  final ClassroomExerciseService assignmentService;
  final QuizService quizService;
  final VoidCallback onLogout;
  final VoidCallback onAddProfileFromPractice;
  final VoidCallback onProfileSaved;
  final int openAddProfileRequestId;
  final Future<void> Function() onCompleteTeacherProfile;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenPracticeTab;
  final VoidCallback onOpenProfileMenu;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final int activeRefreshTick;
  final double bottomPadding;
  final bool hasUnreadNotifications;
  final VoidCallback onNotificationTap;
  final bool showChildProfileDialogOnStart;
  final VoidCallback? onChildProfileDialogShown;
  final Widget? homeHeader;

  EdgeInsets get contentPadding => EdgeInsets.only(
    left: 24,
    right: 24,
    top: activeTab == 0 ? 0 : 24,
    bottom: bottomPadding,
  );
}
