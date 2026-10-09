import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/controllers/classroom_cubit.dart';
import 'package:numi/features/classroom/screens/teacher_class_detail_screen.dart';
import 'package:numi/features/classroom/screens/teacher_create_class_screen.dart';
import 'package:numi/features/classroom/widgets/teacher_create/teacher_create_class_result.dart';
import 'package:numi/features/classroom/screens/parent_room_tab.dart';
import 'package:numi/features/classroom/screens/student_classroom_tab.dart';
import 'package:numi/features/classroom/screens/teacher_classroom_tab.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_factory.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/games/screens/games_coming_soon_tab.dart';
import 'package:numi/features/home/screens/parent/parent_home_tab.dart';
import 'package:numi/features/home/screens/parent/new_parent_home_tab.dart';
import 'package:numi/features/home/screens/student/new_student_home_tab.dart';
import 'package:numi/features/home/screens/teacher/teacher_home_tab.dart';
import 'package:numi/features/classroom_exercise/screens/teacher_study_tab.dart';
import 'package:numi/features/classroom_exercise/screens/teacher_classroom_exercise_detail_screen.dart';
import 'package:numi/features/classroom_exercise/helpers/teacher_exercise_helpers.dart';
import 'package:numi/features/profile/helpers/profile_identity_helpers.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/grade_selection_screen.dart';
import 'package:numi/features/exam/screens/grade_roadmap_screen.dart';
import 'package:numi/features/exam/screens/exam_attempt_screen.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/screens/exam_review_screen.dart';
import 'package:numi/features/exam/screens/parent_assessment_tab.dart';
import 'package:numi/features/exam/screens/open_initial_assessment_from_home.dart';
import 'package:numi/features/settings/screens/setting_tab.dart';
import 'package:numi/features/welcome/screens/welcome_assessment_intro_screen.dart';
import 'package:numi/shared/layouts/page_header.dart';

class AppDashboardTabFactory implements DashboardTabFactory {
  const AppDashboardTabFactory();

  // Set to false to restore the original Parent Home.
  static const bool _useNewParentHome = true;
  // Set to false to restore the original Student Home.
  static const bool _useNewStudentHome = true;

  @override
  Widget buildTab({
    required BuildContext context,
    required ProfileRole role,
    required DashboardTabArgs args,
  }) {
    return switch (role) {
      ProfileRole.parent => _buildParent(context, args),
      ProfileRole.student =>
        args.activeTab == DashboardTabId.room
            ? _buildStudentClassroom(args)
            : _buildParent(context, args, useActiveStudentProfileData: true),
      ProfileRole.teacher => _buildTeacher(args),
    };
  }

  Widget _buildParent(
    BuildContext context,
    DashboardTabArgs args, {
    bool useActiveStudentProfileData = false,
  }) {
    final usesNewHome = useActiveStudentProfileData
        ? _useNewStudentHome
        : _useNewParentHome;
    return switch (args.activeTab) {
      DashboardTabId.home =>
        (useActiveStudentProfileData
            ? (_useNewStudentHome
                  ? NewStudentHomeContent.new
                  : ParentHomeContent.new)
            : (_useNewParentHome
                  ? NewParentHomeContent.new
                  : ParentHomeContent.new))(
          user: args.session.user,
          profiles: args.session.profiles,
          activeProfile: args.session.activeProfile,
          isActive: args.isActive,
          activeRefreshTick: args.activeRefreshTick,
          initialGrades: args.session.initialGrades,
          gradeService: args.services.gradeService,
          examService: args.services.examService,
          onOpenAssessment: (context) => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => GradeSelectionScreen(
                user: args.session.user,
                initialGrades: args.session.initialGrades,
                gradeService: args.services.gradeService,
                examType: examTypeAssessment,
                profileId: profileStableId(args.session.activeProfile),
                initialGradeId: profileGradeStableId(
                  args.session.activeProfile,
                ),
                initialGradeLabel: args.session.activeProfile?.grade?.label,
              ),
            ),
          ),
          onOpenInitialAssessment: (context) =>
              _openAssessmentFromHome(context, args, showIntro: usesNewHome),
          onOpenExamReview: _openHomeExamReview,
          onCreateStudentProfile: (context) =>
              _openCreateStudentProfile(context, args),
          onOpenGradeRoadmap: (context) => _openGradeRoadmap(context, args),
          onResumeAssessment: (context, exam) =>
              _resumeAssessment(context, args, exam),
          onRefreshProfiles: args.actions.onRefreshProfiles,
          onActivateProfile: args.actions.onActivateProfile,
          onProfileSaved: args.actions.onProfileSaved,
          onOpenProfileMenu: args.actions.onOpenProfileMenu,
          onOpenClassroomTab: args.actions.onOpenClassroomTab,
          onOpenGamesTab: args.actions.onOpenGamesTab,
          onParentAssessmentStateChanged:
              args.actions.onParentAssessmentStateChanged,
          bottomPadding: args.presentation.bottomPadding,
          homeHeader: args.presentation.homeHeader,
          showChildProfileDialogOnStart: false,
          onChildProfileDialogShown: args.actions.onChildProfileDialogShown,
          useActiveStudentProfileData: useActiveStudentProfileData,
        ),
      DashboardTabId.assessment => ParentAssessmentTab(
        user: args.session.user,
        activeProfile: args.session.activeProfile,
        isActive: args.isActive,
        activeRefreshTick: args.activeRefreshTick,
        initialGrades: args.session.initialGrades,
        gradeService: args.services.gradeService,
        examService: args.services.examService,
        bottomPadding: args.presentation.bottomPadding,
        useActiveStudentProfileData: useActiveStudentProfileData,
      ),
      DashboardTabId.room => ParentRoomTab(
        profiles: args.session.profiles,
        activeProfile: args.session.activeProfile,
        isActive: args.isActive,
        activeRefreshTick: args.activeRefreshTick,
        assignmentService: args.services.assignmentService,
        onRefreshProfiles: args.actions.onRefreshProfiles,
        onOpenClassroomTab: args.actions.onOpenClassroomTab,
        onOpenProfileMenu: args.actions.onOpenProfileMenu,
        bottomPadding: args.presentation.bottomPadding,
        onOpenExamReview: _openRoomExamReview,
        onCreateStudentProfile: (context) =>
            _openCreateStudentProfile(context, args),
      ),
      DashboardTabId.games => GamesComingSoonTab(
        bottomPadding: args.presentation.bottomPadding,
      ),
      DashboardTabId.settings => _buildSettings(args),
      DashboardTabId.learning => _buildLearning(
        context,
        args,
        useActiveStudentProfileData: useActiveStudentProfileData,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildLearning(
    BuildContext context,
    DashboardTabArgs args, {
    required bool useActiveStudentProfileData,
  }) {
    final profileId = profileStableId(args.session.activeProfile);
    if (profileId == null || profileId <= 0) {
      return Column(
        children: [
          const _LearningPageHeader(),
          Expanded(
            child: Center(
              child: Text(context.getText(AppKeys.parentNoStudentTitle)),
            ),
          ),
        ],
      );
    }
    final buildContent = useActiveStudentProfileData
        ? NewStudentHomeContent.new
        : NewParentHomeContent.new;
    return buildContent(
      user: args.session.user,
      profiles: args.session.profiles,
      activeProfile: args.session.activeProfile,
      isActive: args.isActive,
      activeRefreshTick: args.activeRefreshTick,
      initialGrades: args.session.initialGrades,
      gradeService: args.services.gradeService,
      examService: args.services.examService,
      onRefreshProfiles: args.actions.onRefreshProfiles,
      onActivateProfile: args.actions.onActivateProfile,
      onProfileSaved: args.actions.onProfileSaved,
      onOpenProfileMenu: args.actions.onOpenProfileMenu,
      onOpenClassroomTab: args.actions.onOpenClassroomTab,
      onOpenGamesTab: args.actions.onOpenGamesTab,
      onParentAssessmentStateChanged:
          args.actions.onParentAssessmentStateChanged,
      bottomPadding: args.presentation.bottomPadding,
      homeHeader: const _LearningPageHeader(),
      showAssessmentList: true,
      onOpenInitialAssessment: (context) =>
          _openAssessmentFromHome(context, args, showIntro: true),
      onOpenExamReview: _openHomeExamReview,
      onOpenGradeRoadmap: (context) => _openGradeRoadmap(context, args),
      onResumeAssessment: (context, exam) =>
          _resumeAssessment(context, args, exam),
    );
  }

  Future<void> _openGradeRoadmap(BuildContext context, DashboardTabArgs args) {
    final profileId = profileStableId(args.session.activeProfile);
    if (profileId == null || profileId <= 0) return Future<void>.value();
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GradeRoadmapScreen(
          profileId: profileId,
          examService: args.services.examService,
          user: args.session.user,
          initialGrades: args.session.initialGrades,
          gradeService: args.services.gradeService,
        ),
      ),
    );
  }

  Future<void> _resumeAssessment(
    BuildContext context,
    DashboardTabArgs args,
    GeneratedExam exam,
  ) {
    final profileId = profileStableId(args.session.activeProfile);
    if (profileId == null || profileId <= 0) return Future<void>.value();
    final homeRoute = ModalRoute.of(context);
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ExamAttemptScreen(
          examService: args.services.examService,
          initialExam: exam,
          examType: exam.examType ?? examTypeAssessment,
          gradeLabel: AssessmentFlowPolicy.gradeLabel(exam.grade ?? 0),
          profileId: profileId,
          allowQuestionNavigation: false,
          showQuestionNavigation: false,
          isResumedAssessment: true,
          onResultBack: () {
            if (!context.mounted) return;
            Navigator.of(context).popUntil(
              homeRoute == null
                  ? (route) => route.isFirst
                  : (route) => identical(route, homeRoute),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openRoomExamReview(BuildContext context, GeneratedExam exam) {
    final examId = exam.examId ?? exam.id;
    if (examId == null || examId <= 0) return Future<void>.value();
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ExamReviewScreen(examId: examId, initialExam: exam),
      ),
    );
  }

  Future<void> _openCreateStudentProfile(
    BuildContext context,
    DashboardTabArgs args,
  ) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Material(
          color: context.themeColors.pageBackground,
          child: SafeArea(
            child: SettingTab.page(
              user: args.session.user,
              profiles: args.session.profiles,
              activeProfile: args.session.activeProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: args.actions.onActivateProfile,
              onRefreshProfiles: args.actions.onRefreshProfiles,
              onProfileSaved: args.actions.onProfileSaved,
              bottomPadding: 0,
              initialView: SettingPageView.profile,
              isPushedPage: true,
              openAddProfileOnStart: true,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAssessmentFromHome(
    BuildContext context,
    DashboardTabArgs args, {
    required bool showIntro,
  }) {
    final profileId = profileStableId(args.session.activeProfile);
    if (showIntro && profileId != null && profileId > 0) {
      return Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => WelcomeAssessmentIntroScreen(
            profileId: profileId,
            onAssessment: (_) => openInitialAssessmentFromHome(
              context: context,
              examService: args.services.examService,
              profileId: profileId,
              gradeLabel: args.session.activeProfile?.grade?.label,
            ),
          ),
        ),
      );
    }
    return openInitialAssessmentFromHome(
      context: context,
      examService: args.services.examService,
      profileId: profileId,
      gradeLabel: args.session.activeProfile?.grade?.label,
    );
  }

  Future<void> _openHomeExamReview(BuildContext context, GeneratedExam exam) {
    final examId = exam.examId ?? exam.userAiExamId ?? exam.id;
    final userExamId = exam.userExamId;
    final validUserExamId = userExamId != null && userExamId > 0
        ? userExamId
        : null;
    if (validUserExamId == null && (examId == null || examId <= 0)) {
      return Future<void>.value();
    }
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ExamReviewScreen(
          examId: validUserExamId == null ? examId : null,
          userExamId: validUserExamId,
          examType: exam.examType,
          initialExam: exam,
        ),
      ),
    );
  }

  Widget _buildStudentClassroom(DashboardTabArgs args) => StudentClassroomTab(
    bottomPadding: args.presentation.bottomPadding,
    user: args.session.user,
    activeProfile: args.session.activeProfile,
    classroomService: args.services.classroomService,
    isActive: args.isActive,
    activeRefreshTick: args.activeRefreshTick,
  );

  Widget _buildTeacher(DashboardTabArgs args) {
    return switch (args.activeTab) {
      DashboardTabId.home => TeacherHomeTab(
        user: args.session.user,
        activeProfile: args.session.activeProfile,
        bottomPadding: args.presentation.bottomPadding,
        onCompleteProfile: args.actions.onCompleteTeacherProfile,
        onOpenClassroomTab: args.actions.onOpenClassroomTab,
        onOpenExercisesTab: args.actions.onOpenExercisesTab,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
        hasUnreadNotifications: args.presentation.hasUnreadNotifications,
        onNotificationTap: args.actions.onNotificationTap,
        onCreateClass: (context) async {
          final result = await Navigator.of(context)
              .push<TeacherCreateClassResult>(
                MaterialPageRoute<TeacherCreateClassResult>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ClassroomCubit>(),
                    child: TeacherCreateClassScreen(
                      user: args.session.user,
                      activeProfile: args.session.activeProfile,
                    ),
                  ),
                ),
              );
          return result?.classroom;
        },
        onOpenClassDetail: (context, classroom, initiallyExpanded) async {
          final classroomId = classroom.stableId;
          final profileId = profileStableId(args.session.activeProfile);
          if (classroomId == null || profileId == null) {
            return;
          }
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: context.read<ClassroomCubit>(),
                child: TeacherClassDetailScreen(
                  classroomId: classroomId,
                  profileId: profileId,
                  userId: args.session.user?.id,
                  initialClassroom: classroom,
                  initiallyExpanded: initiallyExpanded,
                ),
              ),
            ),
          );
        },
        onOpenAssignmentDetail: (context, exercise) {
          final exerciseId = exercise.stableId;
          final profileId = profileStableId(args.session.activeProfile);
          if (exerciseId == null || profileId == null) {
            return;
          }
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => TeacherClassroomExerciseDetailScreen(
                exerciseId: exerciseId,
                profileId: profileId,
                initialExercise: exercise,
                purpose: teacherExercisePurpose(exercise),
                exerciseService: args.services.assignmentService,
              ),
            ),
          );
        },
      ),
      DashboardTabId.classroom => TeacherClassroomTab(
        user: args.session.user,
        activeProfile: args.session.activeProfile,
        bottomPadding: args.presentation.bottomPadding,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      ),
      DashboardTabId.study => TeacherStudyTab(
        user: args.session.user,
        activeProfile: args.session.activeProfile,
        bottomPadding: args.presentation.bottomPadding,
        classroomService: args.services.classroomService,
        exerciseService: args.services.assignmentService,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      ),
      DashboardTabId.members => const SizedBox.shrink(),
      DashboardTabId.settings => _buildSettings(args),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSettings(DashboardTabArgs args) => SettingTab(
    user: args.session.user,
    profiles: args.session.profiles,
    activeProfile: args.session.activeProfile,
    profileLoadError: args.session.profileLoadError,
    onLogout: args.actions.onLogout,
    onActivateProfile: args.actions.onActivateProfile,
    onRefreshProfiles: args.actions.onRefreshProfiles,
    onProfileSaved: args.actions.onProfileSaved,
    openAddProfileRequestId: args.presentation.openAddProfileRequestId,
    bottomPadding: args.presentation.bottomPadding,
    isActive: args.isActive,
  );
}

class _LearningPageHeader extends StatelessWidget {
  const _LearningPageHeader();

  @override
  Widget build(BuildContext context) =>
      PageHeader(title: context.getText(AppKeys.learningTabTitle));
}
