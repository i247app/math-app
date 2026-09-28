import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/app/composition/app_dashboard_tab_factory.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/exam_attempt_screen.dart';
import 'package:numi/features/exam/screens/grade_roadmap_screen.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_grade_ribbon.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/home/screens/parent/new_parent_home_tab.dart';
import 'package:numi/features/home/screens/student/new_student_home_tab.dart';
import 'package:numi/features/home/widgets/sections/banner/banner.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/welcome/screens/welcome_assessment_intro_screen.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final hasAssessment in [false, true]) {
    testWidgets('new parent home shows chart and actions without banner '
        'when hasAssessment=$hasAssessment', (tester) async {
      HomeProfileCache.instance.invalidateProfile(77);
      addTearDown(() => HomeProfileCache.instance.invalidateProfile(77));
      final originalLanguage = AppLanguageState.current;
      final lingo = LingoProvider();
      addTearDown(() {
        AppLanguageState.current = originalLanguage;
        lingo.dispose();
      });
      var assessmentOpens = 0;
      var learningOpens = 0;
      final examService = _ExamService(hasAssessment);

      await tester.pumpWidget(
        RepositoryProvider<HomeLayoutService>.value(
          value: const _HomeService(),
          child: LingoScope(
            lingo: lingo,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: Scaffold(
                body: NewParentHomeContent(
                  user: null,
                  profiles: const <UserProfile>[],
                  activeProfile: const UserProfile(profileId: 77),
                  isActive: true,
                  activeRefreshTick: 0,
                  initialGrades: const [],
                  gradeService: _GradeService(),
                  examService: examService,
                  onRefreshProfiles: () async {},
                  onActivateProfile: (_) async {},
                  onProfileSaved: () {},
                  onOpenProfileMenu: () {},
                  onOpenClassroomTab: () {},
                  onOpenGamesTab: () {},
                  onOpenLearningTab: () => learningOpens++,
                  onParentAssessmentStateChanged: (_) {},
                  onOpenInitialAssessment: (_) async => assessmentOpens++,
                  bottomPadding: 0,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AssessmentGradeRibbon), findsOneWidget);
      expect(find.byType(HomeBanner), findsNothing);
      expect(find.byType(AssessmentProgressionChart), findsOneWidget);
      final chart = tester.widget<AssessmentProgressionChart>(
        find.byType(AssessmentProgressionChart),
      );
      expect(chart.chartHeight, 150);
      expect(find.text('Cấp độ'), findsOneWidget);
      expect(find.text('Trend'), findsOneWidget);
      expect(find.text('CẤP ĐỘ'), findsOneWidget);
      expect(find.byType(LearningStreakCard), findsNothing);
      expect(find.text('Đánh Giá Trình Độ'), findsOneWidget);
      expect(find.text('Học & Luyện Tập'), findsOneWidget);

      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpAndSettle();
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Trend'), findsOneWidget);
      expect(find.text('LEVEL'), findsOneWidget);
      expect(find.text('Assessment Test'), findsOneWidget);
      expect(find.text('Learning & Practice'), findsOneWidget);

      await tester.ensureVisible(find.text('Assessment Test'));
      await tester.tap(find.text('Assessment Test'));
      await tester.pumpAndSettle();
      expect(assessmentOpens, 1);

      await tester.ensureVisible(find.text('Learning & Practice'));
      await tester.tap(find.text('Learning & Practice'));
      await tester.pumpAndSettle();
      expect(learningOpens, 1);
      expect(find.byType(GradeRoadmapScreen), findsNothing);
      expect(find.text('Learning & Practice'), findsOneWidget);

      await tester.tap(find.text('Learning & Practice'));
      await tester.pumpAndSettle();
      expect(learningOpens, 2);
    });
  }

  testWidgets(
    'student dashboard uses new home with the active student profile',
    (tester) async {
      HomeProfileCache.instance.invalidateProfile(78);
      addTearDown(() => HomeProfileCache.instance.invalidateProfile(78));
      final originalLanguage = AppLanguageState.current;
      final lingo = LingoProvider();
      addTearDown(() {
        AppLanguageState.current = originalLanguage;
        lingo.dispose();
      });
      final homeService = _RecordingStudentHomeService();
      final examService = _ExamService(false);
      var activeTab = 0;

      await tester.pumpWidget(
        RepositoryProvider<HomeLayoutService>.value(
          value: homeService,
          child: LingoScope(
            lingo: lingo,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setTabState) =>
                      const AppDashboardTabFactory().buildTab(
                        context: context,
                        role: ProfileRole.student,
                        args: DashboardTabArgs(
                          activeTab: activeTab,
                          isActive: true,
                          user: null,
                          profiles: const [UserProfile(profileId: 77)],
                          activeProfile: const UserProfile(profileId: 78),
                          profileLoadError: null,
                          onRefreshProfiles: _noopAsync,
                          onActivateProfile: _noopActivate,
                          initialGrades: const [],
                          gradeService: _GradeService(),
                          classroomService: _ClassroomService(),
                          assignmentService: _ClassroomExerciseService(),
                          examService: examService,
                          onLogout: _noop,
                          onAddProfileFromGames: _noop,
                          onProfileSaved: _noop,
                          openAddProfileRequestId: 0,
                          onCompleteTeacherProfile: _noopAsync,
                          onOpenClassroomTab: _noop,
                          onOpenGamesTab: _noop,
                          onOpenLearningTab: () =>
                              setTabState(() => activeTab = 5),
                          onOpenExercisesTab: _noop,
                          onOpenProfileMenu: _noop,
                          onParentAssessmentStateChanged: _noopAssessmentState,
                          activeRefreshTick: 0,
                          bottomPadding: 0,
                          hasUnreadNotifications: false,
                          onNotificationTap: _noop,
                          showChildProfileDialogOnStart: true,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NewStudentHomeContent), findsOneWidget);
      expect(find.byType(AssessmentProgressionChart), findsOneWidget);
      expect(find.text('Cấp độ'), findsOneWidget);
      expect(find.text('Trend'), findsOneWidget);
      expect(find.text('CẤP ĐỘ'), findsOneWidget);
      expect(find.text('Đánh Giá Trình Độ'), findsOneWidget);
      expect(find.text('Học & Luyện Tập'), findsOneWidget);

      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpAndSettle();
      expect(find.text('Assessment Test'), findsOneWidget);
      expect(find.text('Learning & Practice'), findsOneWidget);
      expect(homeService.profileIds, [78]);
      expect(examService.progressProfileIds, [78]);

      await tester.tap(find.text('Learning & Practice'));
      await tester.pumpAndSettle();
      expect(activeTab, 5);
      final roadmap = tester.widget<GradeRoadmapScreen>(
        find.byType(GradeRoadmapScreen),
      );
      expect(roadmap.profileId, 78);
      expect(roadmap.showCloseButton, isFalse);
      expect(find.byKey(const ValueKey('grade-roadmap-close')), findsNothing);
    },
  );

  for (final role in [ProfileRole.parent, ProfileRole.student]) {
    for (final hasAssessment in [false, true]) {
      testWidgets('$role home routes assessment with history=$hasAssessment', (
        tester,
      ) async {
        const profileId = 79;
        HomeProfileCache.instance.invalidateProfile(profileId);
        addTearDown(
          () => HomeProfileCache.instance.invalidateProfile(profileId),
        );
        final lingo = LingoProvider();
        addTearDown(lingo.dispose);
        final examService = _ExamService(hasAssessment);

        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: [
              RepositoryProvider<HomeLayoutService>.value(
                value: const _HomeService(),
              ),
              RepositoryProvider<ExamService>.value(value: examService),
            ],
            child: LingoScope(
              lingo: lingo,
              child: MaterialApp(
                theme: AppTheme.light(),
                home: Scaffold(
                  body: Builder(
                    builder: (context) =>
                        const AppDashboardTabFactory().buildTab(
                          context: context,
                          role: role,
                          args: DashboardTabArgs(
                            activeTab: 0,
                            isActive: true,
                            user: const LoginUser(id: 271),
                            profiles: const [],
                            activeProfile: UserProfile(
                              profileId: profileId,
                              role: role == ProfileRole.parent
                                  ? 'PARENT'
                                  : 'STUDENT',
                            ),
                            profileLoadError: null,
                            onRefreshProfiles: _noopAsync,
                            onActivateProfile: _noopActivate,
                            initialGrades: const [],
                            gradeService: _GradeService(),
                            classroomService: _ClassroomService(),
                            assignmentService: _ClassroomExerciseService(),
                            examService: examService,
                            onLogout: _noop,
                            onAddProfileFromGames: _noop,
                            onProfileSaved: _noop,
                            openAddProfileRequestId: 0,
                            onCompleteTeacherProfile: _noopAsync,
                            onOpenClassroomTab: _noop,
                            onOpenGamesTab: _noop,
                            onOpenLearningTab: _noop,
                            onOpenExercisesTab: _noop,
                            onOpenProfileMenu: _noop,
                            onParentAssessmentStateChanged:
                                _noopAssessmentState,
                            activeRefreshTick: 0,
                            bottomPadding: 0,
                            hasUnreadNotifications: false,
                            onNotificationTap: _noop,
                            showChildProfileDialogOnStart: false,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final assessmentAction = find.byKey(
          const ValueKey('parent-home-assessment-action'),
        );
        await tester.ensureVisible(assessmentAction);
        await tester.tap(assessmentAction);
        await tester.pumpAndSettle();

        expect(examService.gradeStatsProfileIds, isEmpty);
        if (hasAssessment) {
          expect(find.byType(WelcomeAssessmentIntroScreen), findsNothing);
          expect(find.byType(ExamAttemptScreen), findsOneWidget);
          expect(examService.generatedProfileIds, [profileId]);
        } else {
          expect(find.byType(WelcomeAssessmentIntroScreen), findsOneWidget);
          expect(find.byType(ExamAttemptScreen), findsNothing);
          expect(examService.generatedProfileIds, isEmpty);
          expect(examService.progressProfileIds.last, profileId);

          await tester.tap(
            find.byKey(const ValueKey('welcome-assessment-intro-action')),
          );
          await tester.pumpAndSettle();
          expect(find.byType(ExamAttemptScreen), findsOneWidget);
          expect(examService.generatedProfileIds, [profileId]);
        }
      });
    }
  }
}

void _noop() {}
Future<void> _noopAsync() async {}
Future<void> _noopActivate(UserProfile _) async {}
void _noopAssessmentState(bool _) {}

class _RecordingStudentHomeService implements HomeLayoutService {
  final List<int> profileIds = [];

  @override
  Future<HomeLayout> getLayout({required int profileId}) async {
    profileIds.add(profileId);
    return const HomeLayout(role: 'STUDENT');
  }
}

class _HomeService implements HomeLayoutService {
  const _HomeService();

  @override
  Future<HomeLayout> getLayout({required int profileId}) async =>
      const HomeLayout(role: 'PARENT');
}

class _ExamService implements ExamService {
  _ExamService(this.hasAssessment);

  final bool hasAssessment;
  final List<int> gradeStatsProfileIds = [];
  final List<int> progressProfileIds = [];
  final List<int?> generatedProfileIds = [];

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) async {
    generatedProfileIds.add(profileId);
    return const GeneratedExam(
      examId: 101,
      examType: examTypeAssessment,
      questions: [
        ExamQuestion(
          questionName: '1 + 1 = ?',
          questionNumber: 1,
          answers: [
            ExamAnswer(label: 'A', content: '2'),
            ExamAnswer(label: 'B', content: '3'),
          ],
        ),
      ],
    );
  }

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    if (examType == examTypeGrade) {
      gradeStatsProfileIds.add(profileId);
      return const [];
    }
    return hasAssessment
        ? const [
            ExamStats(
              correctNumber: 8,
              scorePercentage: 80,
              skippedNumber: 0,
              totalQuestions: 10,
              status: 'COMPLETE',
              grade: 2,
            ),
          ]
        : const [];
  }

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
    String examType = examTypeAssessment,
  }) async {
    progressProfileIds.add(profileId);
    return ExamProgressResponse(
      mstatus: 200,
      series: hasAssessment
          ? [
              ExamProgressPoint(
                completedDt: DateTime.utc(2026, 9, 22),
                correctNumber: 8,
                examId: 12,
                score: 8,
                scorePct: 80,
                sequence: 1,
                totalQuestions: 10,
                status: 'COMPLETE',
                grade: 2,
              ),
            ]
          : const [],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _GradeService implements GradeService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ClassroomService implements ClassroomService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ClassroomExerciseService implements ClassroomExerciseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
