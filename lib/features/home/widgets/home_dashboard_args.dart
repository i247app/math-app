part of '../home_screen.dart';

class HomeDashboardArgs {
  const HomeDashboardArgs({
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
    required this.onAddProfileFromReview,
    required this.onProfileSaved,
    required this.openAddProfileRequestId,
    required this.onCompleteTeacherProfile,
    required this.onOpenClassroomTab,
    required this.onOpenReviewTab,
    required this.onOpenProfileMenu,
    required this.onParentAssessmentStateChanged,
    required this.parentHomeEntrance,
    required this.activeRefreshTick,
    required this.bottomPadding,
    required this.headerHeight,
    required this.scale,
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
  final VoidCallback onAddProfileFromReview;
  final VoidCallback onProfileSaved;
  final int openAddProfileRequestId;
  final Future<void> Function() onCompleteTeacherProfile;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenReviewTab;
  final VoidCallback onOpenProfileMenu;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final Animation<double> parentHomeEntrance;
  final int activeRefreshTick;
  final double bottomPadding;
  final double headerHeight;
  final double scale;

  EdgeInsets get contentPadding => EdgeInsets.only(
        left: 24 * scale,
        right: 24 * scale,
        top: headerHeight + (activeTab == 0 ? 0 : 24 * scale),
        bottom: bottomPadding,
      );
}
