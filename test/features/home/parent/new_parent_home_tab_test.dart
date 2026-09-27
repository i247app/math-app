import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/grade_roadmap_screen.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_grade_ribbon.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/home/screens/parent/new_parent_home_tab.dart';
import 'package:numi/features/home/widgets/parent/parent_home_action_button.dart';
import 'package:numi/features/home/widgets/sections/banner/banner.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/models/profile.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final hasAssessment in [false, true]) {
    testWidgets('new parent home shows chart and actions without banner '
        'when hasAssessment=$hasAssessment', (tester) async {
      HomeProfileCache.instance.invalidateProfile(77);
      addTearDown(() => HomeProfileCache.instance.invalidateProfile(77));
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      var assessmentOpens = 0;
      var gameOpens = 0;
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
                  onOpenGamesTab: () => gameOpens++,
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
      expect(find.text('Activity'), findsOneWidget);
      expect(find.byType(LearningStreakCard), findsNothing);
      expect(find.text('Assessment Test'), findsOneWidget);
      expect(find.text('Learning & Practice'), findsOneWidget);

      await tester.ensureVisible(find.text('Assessment Test'));
      await tester.tap(find.text('Assessment Test'));
      await tester.pumpAndSettle();
      expect(assessmentOpens, 1);

      await tester.ensureVisible(find.text('Learning & Practice'));
      final practiceAction = tester.widget<ParentHomeActionButton>(
        find.byKey(const ValueKey('parent-home-practice-action')),
      );
      await tester.tap(find.text('Learning & Practice'));
      practiceAction.onTap();
      await tester.pumpAndSettle();
      expect(gameOpens, 0);
      expect(find.byType(GradeRoadmapScreen), findsOneWidget);
      final roadmap = tester.widget<GradeRoadmapScreen>(
        find.byType(GradeRoadmapScreen),
      );
      expect(roadmap.profileId, 77);
      expect(roadmap.examService, same(examService));
      expect(examService.gradeStatsProfileIds, [77]);

      await tester.tap(find.byKey(const ValueKey('grade-roadmap-close')));
      await tester.pumpAndSettle();
      expect(find.byType(GradeRoadmapScreen), findsNothing);
      expect(find.text('Learning & Practice'), findsOneWidget);

      await tester.tap(find.text('Learning & Practice'));
      await tester.pumpAndSettle();
      expect(find.byType(GradeRoadmapScreen), findsOneWidget);
      expect(examService.gradeStatsProfileIds, [77, 77]);
    });
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
  }) async => ExamProgressResponse(
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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _GradeService implements GradeService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
