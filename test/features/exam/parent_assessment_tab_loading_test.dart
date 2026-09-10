import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/profile/models/grade.dart';
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
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_banner.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

void main() {
  testWidgets('shows only the full skeleton until the initial load settles', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final examService = _PendingExamService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: ParentAssessmentTab(
            user: const LoginUser(id: 981243),
            activeProfile: null,
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

    expect(find.byType(ParentAssessmentFullSkeleton), findsOneWidget);
    expect(find.byType(ParentAssessmentTabBanner), findsNothing);
    expect(find.byType(ParentAssessmentSearchField), findsNothing);
    expect(find.byType(ParentAssessmentEmptyPoster), findsNothing);

    examService.completeWithEmptyPage();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ParentAssessmentFullSkeleton), findsNothing);
    expect(find.byType(ParentAssessmentEmptyPoster), findsOneWidget);
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

    expect(find.byType(AiAssessmentScreen), findsOneWidget);
    expect(
      tester
          .widget<AiAssessmentScreen>(find.byType(AiAssessmentScreen))
          .allowQuestionNavigation,
      isFalse,
    );
    expect(find.byType(GradeSelectionScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('12 + 8 = ?'), findsOneWidget);
  });

  testWidgets('reloads assessments whenever the tab becomes active', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final examService = _CountingExamService();
    addTearDown(lingo.dispose);

    Future<void> pumpAssessmentTab({required bool isActive}) {
      return tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: LingoScope(
            lingo: lingo,
            child: ParentAssessmentTab(
              user: const LoginUser(id: 981243),
              activeProfile: null,
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
    expect(examService.listPageCalls, 0);

    await pumpAssessmentTab(isActive: true);
    await tester.pump();
    expect(examService.listPageCalls, 1);

    await pumpAssessmentTab(isActive: false);
    await pumpAssessmentTab(isActive: true);
    await tester.pump();
    expect(examService.listPageCalls, 2);
  });

  testWidgets('second empty banner selects a grade before using API service', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final examService = _CountingExamService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: RepositoryProvider<ExamShakeService>.value(
          value: const _TestExamShakeService(),
          child: LingoScope(
            lingo: lingo,
            child: ParentAssessmentTab(
              user: const LoginUser(id: 981243),
              activeProfile: null,
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
    await tester.pump();

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
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(AiAssessmentScreen), findsOneWidget);
    expect(
      tester
          .widget<AiAssessmentScreen>(find.byType(AiAssessmentScreen))
          .allowQuestionNavigation,
      isTrue,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('12 + 8 = ?'), findsOneWidget);
  });
}

class _PendingExamService implements ExamService {
  final _pageCompleter = Completer<ExamListResponse>();

  void completeWithEmptyPage() {
    _pageCompleter.complete(const ExamListResponse(mstatus: 1));
  }

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String purpose = examPurposeAssessment,
    String typeOfExam = examTypeGeneral,
    String? gradeLabel,
    int? previousExamId,
    List<String>? chapters,
    int? profileId,
  }) async => _testExam;

  @override
  Future<ExamListResponse> listExamPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) => _pageCompleter.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CountingExamService implements ExamService {
  int listPageCalls = 0;

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String purpose = examPurposeAssessment,
    String typeOfExam = examTypeGeneral,
    String? gradeLabel,
    int? previousExamId,
    List<String>? chapters,
    int? profileId,
  }) async => _testExam;

  @override
  Future<ExamListResponse> listExamPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) async {
    listPageCalls++;
    return const ExamListResponse(mstatus: 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
