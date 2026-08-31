import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';
import 'package:numi/features/quiz/presentation/tabs/parent_assessment_tab.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_empty_poster.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_full_skeleton.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_search_field.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_banner.dart';

void main() {
  testWidgets('shows only the full skeleton until the initial load settles', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final quizService = _PendingQuizService();
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
            quizService: quizService,
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

    quizService.completeWithEmptyPage();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ParentAssessmentFullSkeleton), findsNothing);
    expect(find.byType(ParentAssessmentEmptyPoster), findsOneWidget);
    expect(find.byType(ParentAssessmentTabBanner), findsNothing);
    expect(find.byType(ParentAssessmentSearchField), findsNothing);
  });

  testWidgets('reloads assessments whenever the tab becomes active', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final quizService = _CountingQuizService();
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
              quizService: quizService,
              bottomPadding: 0,
            ),
          ),
        ),
      );
    }

    await pumpAssessmentTab(isActive: false);
    expect(quizService.listPageCalls, 0);

    await pumpAssessmentTab(isActive: true);
    await tester.pump();
    expect(quizService.listPageCalls, 1);

    await pumpAssessmentTab(isActive: false);
    await pumpAssessmentTab(isActive: true);
    await tester.pump();
    expect(quizService.listPageCalls, 2);
  });
}

class _PendingQuizService implements QuizService {
  final _pageCompleter = Completer<QuizListResponse>();

  void completeWithEmptyPage() {
    _pageCompleter.complete(const QuizListResponse(mstatus: 1));
  }

  @override
  Future<QuizListResponse> listQuizPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) => _pageCompleter.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CountingQuizService implements QuizService {
  int listPageCalls = 0;

  @override
  Future<QuizListResponse> listQuizPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) async {
    listPageCalls++;
    return const QuizListResponse(mstatus: 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGradeService implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) async =>
      const <GradeModel>[];
}
