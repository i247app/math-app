import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'package:numi/features/games/screens/games_tab.dart';
import 'package:numi/features/home/screens/parent/parent_home_tab.dart';
import 'package:numi/features/home/screens/teacher/teacher_home_tab.dart';
import 'package:numi/features/classroom_exercise/screens/teacher_study_tab.dart';
import 'package:numi/features/classroom_exercise/screens/teacher_classroom_exercise_detail_screen.dart';
import 'package:numi/features/classroom_exercise/helpers/teacher_exercise_helpers.dart';
import 'package:numi/features/profile/helpers/profile_identity_helpers.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/quiz/data/quiz_snapshot_store.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';
import 'package:numi/features/quiz/screens/grade_selection_screen.dart';
import 'package:numi/features/quiz/screens/quiz_review_entry_screen.dart';
import 'package:numi/features/quiz/screens/parent_assessment_tab.dart';
import 'package:numi/features/settings/screens/setting_tab.dart';

class AppDashboardTabFactory implements DashboardTabFactory {
  const AppDashboardTabFactory({required this.quizSnapshotStore});

  final QuizSnapshotStore quizSnapshotStore;

  @override
  Widget buildTab({
    required BuildContext context,
    required ProfileRole role,
    required DashboardTabArgs args,
  }) {
    return switch (role) {
      ProfileRole.parent => _buildParent(args),
      ProfileRole.student =>
        args.activeTab == 2
            ? _buildStudentClassroom(args)
            : _buildParent(args, useActiveStudentProfileData: true),
      ProfileRole.teacher => _buildTeacher(args),
    };
  }

  Widget _buildParent(
    DashboardTabArgs args, {
    bool useActiveStudentProfileData = false,
  }) {
    return switch (args.activeTab) {
      0 => ParentHomeContent(
        user: args.user,
        profiles: args.profiles,
        activeProfile: args.activeProfile,
        isActive: args.isActive,
        activeRefreshTick: args.activeRefreshTick,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        quizService: args.quizService,
        quizSnapshotStore: quizSnapshotStore,
        onOpenAssessment: (context) => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => GradeSelectionScreen(
              user: args.user,
              initialGrades: args.initialGrades,
              gradeService: args.gradeService,
              quizPurpose: quizPurposeAssessment,
              profileId: profileStableId(args.activeProfile),
              initialGradeId: profileGradeStableId(args.activeProfile),
              initialGradeLabel: args.activeProfile?.grade?.label,
            ),
          ),
        ),
        onOpenQuizReview: (context, quiz) {
          final quizId = quiz.quizId ?? quiz.id;
          if (quizId == null || quizId <= 0) {
            return Future<void>.value();
          }
          return Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) =>
                  QuizReviewScreen(quizId: quizId, initialQuiz: quiz),
            ),
          );
        },
        onCreateStudentProfile: (context) => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => Material(
              color: context.themeColors.pageBackground,
              child: SafeArea(
                child: SettingTab.page(
                  user: args.user,
                  profiles: args.profiles,
                  activeProfile: args.activeProfile,
                  profileLoadError: null,
                  onLogout: () {},
                  onActivateProfile: args.onActivateProfile,
                  onRefreshProfiles: args.onRefreshProfiles,
                  onProfileSaved: args.onProfileSaved,
                  bottomPadding: 0,
                  initialView: SettingPageView.profile,
                  isPushedPage: true,
                  openAddProfileOnStart: true,
                ),
              ),
            ),
          ),
        ),
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
        useActiveStudentProfileData: useActiveStudentProfileData,
      ),
      1 => ParentAssessmentTab(
        user: args.user,
        activeProfile: args.activeProfile,
        isActive: args.isActive,
        activeRefreshTick: args.activeRefreshTick,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        quizService: args.quizService,
        bottomPadding: args.bottomPadding,
        useActiveStudentProfileData: useActiveStudentProfileData,
      ),
      2 => ParentRoomTab(
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
      ),
      3 => GamesTab(
        userId: args.user?.id,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        initialGradeId: profileGradeStableId(args.activeProfile),
        initialGradeLabel: args.activeProfile?.grade?.label,
        bottomPadding: args.bottomPadding,
      ),
      4 => _buildSettings(args),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildStudentClassroom(DashboardTabArgs args) => StudentClassroomTab(
    bottomPadding: args.bottomPadding,
    user: args.user,
    activeProfile: args.activeProfile,
    classroomService: args.classroomService,
    isActive: args.isActive,
    activeRefreshTick: args.activeRefreshTick,
  );

  Widget _buildTeacher(DashboardTabArgs args) {
    return switch (args.activeTab) {
      0 => TeacherHomeTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        onCompleteProfile: args.onCompleteTeacherProfile,
        onOpenClassroomTab: args.onOpenClassroomTab,
        onOpenStudyTab: args.onOpenPracticeTab,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
        hasUnreadNotifications: args.hasUnreadNotifications,
        onNotificationTap: args.onNotificationTap,
        onCreateClass: (context) async {
          final result = await Navigator.of(context)
              .push<TeacherCreateClassResult>(
                MaterialPageRoute<TeacherCreateClassResult>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ClassroomCubit>(),
                    child: TeacherCreateClassScreen(
                      user: args.user,
                      activeProfile: args.activeProfile,
                    ),
                  ),
                ),
              );
          return result?.classroom;
        },
        onOpenClassDetail: (context, classroom, initiallyExpanded) async {
          final classroomId = classroom.stableId;
          final profileId = profileStableId(args.activeProfile);
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
                  userId: args.user?.id,
                  initialClassroom: classroom,
                  initiallyExpanded: initiallyExpanded,
                ),
              ),
            ),
          );
        },
        onOpenAssignmentDetail: (context, exercise) {
          final exerciseId = exercise.stableId;
          final profileId = profileStableId(args.activeProfile);
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
                exerciseService: args.assignmentService,
              ),
            ),
          );
        },
      ),
      1 => TeacherClassroomTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      ),
      2 => TeacherStudyTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        classroomService: args.classroomService,
        exerciseService: args.assignmentService,
        activeRefreshTick: args.activeRefreshTick,
        isActive: args.isActive,
      ),
      3 => const SizedBox.shrink(),
      4 => _buildSettings(args),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSettings(DashboardTabArgs args) => SettingTab(
    user: args.user,
    profiles: args.profiles,
    activeProfile: args.activeProfile,
    profileLoadError: args.profileLoadError,
    onLogout: args.onLogout,
    onActivateProfile: args.onActivateProfile,
    onRefreshProfiles: args.onRefreshProfiles,
    onProfileSaved: args.onProfileSaved,
    openAddProfileRequestId: args.openAddProfileRequestId,
    bottomPadding: args.bottomPadding,
    isActive: args.isActive,
  );
}
