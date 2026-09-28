import 'package:numi/features/home/screens/parent/new_parent_home_tab.dart';

/// Student entry point for the shared new home layout.
class NewStudentHomeContent extends NewParentHomeContent {
  const NewStudentHomeContent({
    super.key,
    required super.user,
    required super.profiles,
    required super.activeProfile,
    required super.isActive,
    required super.activeRefreshTick,
    required super.initialGrades,
    required super.gradeService,
    required super.examService,
    required super.onRefreshProfiles,
    required super.onActivateProfile,
    required super.onProfileSaved,
    required super.onOpenProfileMenu,
    required super.onOpenClassroomTab,
    required super.onOpenGamesTab,
    required super.onParentAssessmentStateChanged,
    required super.bottomPadding,
    super.showChildProfileDialogOnStart,
    super.onChildProfileDialogShown,
    super.homeHeader,
    super.onOpenAssessment,
    super.onOpenInitialAssessment,
    super.onOpenExamReview,
    super.onOpenLearningTab,
    super.onCreateStudentProfile,
    bool useActiveStudentProfileData = true,
  }) : assert(useActiveStudentProfileData),
       super(useActiveStudentProfileData: true);
}
