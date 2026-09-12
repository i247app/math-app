import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_shake_service.dart';
import 'package:numi/features/exam/screens/assessment_screen.dart';
import 'package:numi/features/exam/screens/grade_selection_screen.dart';
import 'package:numi/features/exam/screens/parent_assessment_tab.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_empty_poster.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_full_skeleton.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_search_field.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_banner.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

void main() {
  testWidgets('loads content with a skeleton only after the first banner tap', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final examService = _PendingExamService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: ParentAssessmentTab(
            user: const LoginUser(id: 981243),
            activeProfile: const StudentProfile(
              profileId: 981243,
              role: 'STUDENT',
            ),
            isActive: true,
            activeRefreshTick: 0,
            initialGrades: const <GradeModel>[],
            gradeService: _FakeGradeService(),
            examService: examService,
            bottomPadding: 0,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(examService.statsCalls, 0);
    expect(find.byType(ParentAssessmentEmptyPoster), findsOneWidget);
    expect(find.byType(ParentAssessmentFullSkeleton), findsNothing);
    expect(find.byType(ParentAssessmentTabBanner), findsNothing);
    expect(find.byType(ParentAssessmentSearchField), findsNothing);
    expect(
      find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage(parentHomeAfterReviewBannerAsset)),
      findsOneWidget,
    );

    await tester.tap(
      find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(examService.statsCalls, 1);
    expect(examService.requestedExamTypes, const <String>['ASSESSMENT']);
    expect(find.byType(ParentAssessmentFullSkeleton), findsOneWidget);
    expect(find.byType(ParentAssessmentEmptyPoster), findsNothing);
    expect(find.byType(ParentAssessmentTabBanner), findsNothing);

    examService.completeWithEmptyPage();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ParentAssessmentFullSkeleton), findsNothing);
    expect(find.byType(ParentAssessmentEmptyPoster), findsNothing);
    expect(find.byType(ParentAssessmentTabBanner), findsOneWidget);
    expect(find.byType(ParentAssessmentSearchField), findsOneWidget);

    await tester.tap(find.byType(ParentAssessmentTabBanner));
    await tester.pumpAndSettle();

    expect(find.byType(AiAssessmentScreen), findsOneWidget);
    expect(
      tester
          .widget<AiAssessmentScreen>(find.byType(AiAssessmentScreen))
          .allowQuestionNavigation,
      isFalse,
    );
    expect(
      tester
          .widget<AiAssessmentScreen>(find.byType(AiAssessmentScreen))
          .showQuestionNavigation,
      isFalse,
    );
    expect(find.byType(GradeSelectionScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('12 + 8 = ?'), findsOneWidget);
    expect(
      find.byKey(
        const PageStorageKey<String>('assessment-question-navigation'),
      ),
      findsNothing,
    );
    final questionLabel = tester.widget<Text>(
      find.byKey(const ValueKey('assessment-question-label')),
    );
    expect(questionLabel.data, isNot(contains('/')));
  });

  testWidgets('loads assessments lazily on each content entry', (tester) async {
    final lingo = LingoProvider();
    final examService = _CountingExamService();
    addTearDown(lingo.dispose);

    Future<void> pumpAssessmentTab({required bool isActive}) {
      return tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
            ),
            home: ParentAssessmentTab(
              user: const LoginUser(id: 981243),
              activeProfile: const StudentProfile(
                profileId: 981243,
                role: 'STUDENT',
              ),
              isActive: isActive,
              activeRefreshTick: 0,
              initialGrades: const <GradeModel>[],
              gradeService: _FakeGradeService(),
              examService: examService,
              bottomPadding: 0,
            ),
          ),
        ),
      );
    }

    await pumpAssessmentTab(isActive: false);
    expect(examService.statsCalls, 0);

    await pumpAssessmentTab(isActive: true);
    await tester.pump();
    expect(examService.statsCalls, 0);

    await tester.tap(
      find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
    );
    await tester.pump();
    expect(examService.statsCalls, 1);
    await tester.pump(const Duration(milliseconds: 300));

    await pumpAssessmentTab(isActive: false);
    await pumpAssessmentTab(isActive: true);
    await tester.pump();
    expect(examService.statsCalls, 1);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(
      find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
    );
    await tester.pump();
    expect(examService.statsCalls, 2);
    expect(examService.requestedExamTypes, const <String>[
      'ASSESSMENT',
      'ASSESSMENT',
    ]);
  });

  testWidgets('populated assessment opens from the first landing banner', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final examService = _PopulatedExamService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: ParentAssessmentTab(
            user: const LoginUser(id: 981244),
            activeProfile: const StudentProfile(
              profileId: 981244,
              role: 'STUDENT',
            ),
            isActive: true,
            activeRefreshTick: 0,
            initialGrades: const <GradeModel>[],
            gradeService: _FakeGradeService(),
            examService: examService,
            bottomPadding: 0,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(examService.statsCalls, 0);

    expect(find.byType(ParentAssessmentEmptyPoster), findsOneWidget);
    expect(find.byType(ParentAssessmentTabBanner), findsNothing);
    expect(find.byType(ParentAssessmentSearchField), findsNothing);

    await tester.tap(
      find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('assessment-landing-view')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('assessment-content-view')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ParentAssessmentEmptyPoster), findsNothing);
    expect(find.byType(ParentAssessmentTabBanner), findsOneWidget);
    expect(find.byType(ParentAssessmentSearchField), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.byType(AiAssessmentScreen), findsNothing);
    final statsCard = tester.widget<AssessmentResultListItemCard>(
      find.byType(AssessmentResultListItemCard),
    );
    expect(statsCard.exam.userExamId, 8001);
    expect(statsCard.exam.grading?.correctNumber, 13);
    expect(statsCard.exam.grading?.totalQuestions, 20);
    expect(statsCard.onTap, isNotNull);

    await tester.tap(find.byType(ParentAssessmentTabBanner));
    await tester.pumpAndSettle();

    expect(find.byType(GradeSelectionScreen), findsNothing);
    final assessment = tester.widget<AiAssessmentScreen>(
      find.byType(AiAssessmentScreen),
    );
    expect(assessment.allowQuestionNavigation, isFalse);
    expect(assessment.showQuestionNavigation, isFalse);
  });

  testWidgets('back from populated content restores the two-banner landing', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final examService = _PopulatedExamService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: ParentAssessmentTab(
            user: const LoginUser(id: 981244),
            activeProfile: const StudentProfile(
              profileId: 981244,
              role: 'STUDENT',
            ),
            isActive: true,
            activeRefreshTick: 0,
            initialGrades: const <GradeModel>[],
            gradeService: _FakeGradeService(),
            examService: examService,
            bottomPadding: 0,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(
      find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byType(AppBackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ParentAssessmentEmptyPoster), findsOneWidget);
    expect(find.byType(ParentAssessmentTabBanner), findsNothing);
    expect(
      find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage(parentHomeAfterReviewBannerAsset)),
      findsOneWidget,
    );
  });

  testWidgets('second empty banner selects a grade before using API service', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final examService = _CountingExamService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      RepositoryProvider<ExamShakeService>.value(
        value: const _TestExamShakeService(),
        child: LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
            ),
            home: ParentAssessmentTab(
              user: const LoginUser(id: 981243),
              activeProfile: const StudentProfile(
                profileId: 981243,
                role: 'STUDENT',
              ),
              isActive: true,
              activeRefreshTick: 0,
              initialGrades: const <GradeModel>[
                GradeModel(id: 3, label: 'Lớp 3', displayOrder: 3),
              ],
              gradeService: _FakeGradeService(),
              examService: examService,
              bottomPadding: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final secondBanner = find.image(
      const AssetImage(parentHomeAfterReviewBannerAsset),
    );
    await tester.ensureVisible(secondBanner);
    await tester.pump();
    await tester.tap(secondBanner);
    await tester.pumpAndSettle();

    expect(examService.statsCalls, 0);
    expect(find.byType(GradeSelectionScreen), findsOneWidget);
    final gradeSelection = tester.widget<GradeSelectionScreen>(
      find.byType(GradeSelectionScreen),
    );
    expect(gradeSelection.examService, same(examService));
    expect(gradeSelection.examShakeService, isNull);

    await tester.tap(
      find.byKey(const ValueKey('grade-card-assets/icons/3.svg')),
    );
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(find.byType(AiAssessmentScreen), findsOneWidget);
    expect(
      tester
          .widget<AiAssessmentScreen>(find.byType(AiAssessmentScreen))
          .allowQuestionNavigation,
      isTrue,
    );
    expect(
      tester
          .widget<AiAssessmentScreen>(find.byType(AiAssessmentScreen))
          .showQuestionNavigation,
      isTrue,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('12 + 8 = ?'), findsOneWidget);
  });
}

class _PendingExamService implements ExamService {
  final _statsCompleter = Completer<List<ExamStats>>();
  int statsCalls = 0;
  final List<String> requestedExamTypes = <String>[];

  void completeWithEmptyPage() {
    _statsCompleter.complete(const <ExamStats>[]);
  }

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? profileId,
  }) async => _testExam;

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) {
    statsCalls++;
    requestedExamTypes.add(examType);
    return _statsCompleter.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CountingExamService implements ExamService {
  int statsCalls = 0;
  final List<String> requestedExamTypes = <String>[];

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? profileId,
  }) async => _testExam;

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    statsCalls++;
    requestedExamTypes.add(examType);
    return const <ExamStats>[];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PopulatedExamService extends _CountingExamService {
  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    statsCalls++;
    requestedExamTypes.add(examType);
    return <ExamStats>[
      ExamStats(
        correctNumber: 13,
        scorePercentage: 65,
        skippedNumber: 0,
        totalQuestions: 20,
        examType: examTypeAssessment,
        userExamId: 8001,
        status: 'COMPLETE',
        grade: 2,
        level: 1,
        lastSubmittedDt: DateTime.utc(2026, 9, 10, 20, 35),
        review: 'Tiến bộ tốt.',
      ),
    ];
  }
}

class _FakeGradeService implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) async =>
      const <GradeModel>[];
}

class _TestExamShakeService implements ExamShakeService {
  const _TestExamShakeService();

  @override
  Future<void> aiShake() async {}
}

const _testExam = GeneratedExam(
  examId: 7001,
  questions: <ExamQuestion>[
    ExamQuestion(
      questionName: '12 + 8 = ?',
      questionNumber: 1,
      rightAnswer: 'C',
      answers: <ExamAnswer>[
        ExamAnswer(label: 'A', content: '18'),
        ExamAnswer(label: 'B', content: '19'),
        ExamAnswer(label: 'C', content: '20'),
        ExamAnswer(label: 'D', content: '21'),
      ],
    ),
  ],
);
