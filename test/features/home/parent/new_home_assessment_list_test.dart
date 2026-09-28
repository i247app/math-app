import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_active_card.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_list_skeleton.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_pagination.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/home/widgets/parent/new_home_assessment_list.dart';

void main() {
  testWidgets('learning list shows skeleton until stats finish loading', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    Widget buildList(bool isLoading) => LingoScope(
      lingo: lingo,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: NewHomeAssessmentList(
            assessments: const [GeneratedExam(userExamId: 1, questions: [])],
            activeAssessment: const GeneratedExam(examId: 99, questions: []),
            isLoading: isLoading,
            isOpeningActiveAssessment: false,
            errorMessage: null,
            onOpenExam: (_) {},
            onResumeExam: () {},
            onRetry: () {},
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildList(true));
    expect(find.byType(ParentAssessmentListSkeleton), findsOneWidget);
    expect(find.byType(ParentAssessmentActiveCard), findsNothing);
    expect(find.byType(AssessmentResultListItemCard), findsNothing);

    await tester.pumpWidget(buildList(false));
    expect(find.byType(ParentAssessmentListSkeleton), findsNothing);
    expect(find.byType(ParentAssessmentActiveCard), findsOneWidget);
    expect(find.byType(AssessmentResultListItemCard), findsOneWidget);
  });

  testWidgets('learning list shows active and completed exams without search', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    final exams = List.generate(
      7,
      (index) => GeneratedExam(
        userExamId: index + 1,
        title: 'Assessment ${index + 1}',
        createDt: '2026-09-${(index + 1).toString().padLeft(2, '0')}',
        questions: const [],
      ),
    );
    GeneratedExam? openedExam;
    var resumeCount = 0;

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: NewHomeAssessmentList(
                assessments: exams,
                activeAssessment: const GeneratedExam(
                  examId: 99,
                  questions: [],
                ),
                isLoading: false,
                isOpeningActiveAssessment: false,
                errorMessage: null,
                onOpenExam: (exam) => openedExam = exam,
                onResumeExam: () => resumeCount++,
                onRetry: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ParentAssessmentActiveCard), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Đánh Giá'), findsNothing);
    expect(find.byType(AssessmentResultListItemCard), findsNWidgets(5));
    expect(find.text('Assessment 1'), findsOneWidget);
    expect(find.byType(ParentAssessmentPagination), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('parent-assessment-active-continue')),
    );
    expect(resumeCount, 1);

    await tester.ensureVisible(find.byType(ParentAssessmentPagination));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();
    expect(find.byType(AssessmentResultListItemCard), findsNWidgets(2));
    expect(find.text('Assessment 7'), findsOneWidget);

    await tester.tap(find.text('Assessment 7'));
    expect(openedExam?.userExamId, 7);
  });
}
