import 'package:flutter/material.dart';

import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';

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
    required this.onOpenHistoryTab,
    required this.onOpenProfileMenu,
    required this.onParentAssessmentStateChanged,
    required this.parentHomeEntrance,
    required this.activeRefreshTick,
    required this.bottomPadding,
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
  final VoidCallback onOpenHistoryTab;
  final VoidCallback onOpenProfileMenu;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final Animation<double> parentHomeEntrance;
  final int activeRefreshTick;
  final double bottomPadding;
  final Widget? homeHeader;

  EdgeInsets get contentPadding => EdgeInsets.only(
    left: 24,
    right: 24,
    top: activeTab == 0 ? 0 : 24,
    bottom: bottomPadding,
  );
}
