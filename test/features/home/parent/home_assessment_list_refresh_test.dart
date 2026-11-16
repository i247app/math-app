import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_list_skeleton.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/home/widgets/parent/home_assessment_list.dart';

GeneratedExam exam(int id, {String? title}) => GeneratedExam(
  userExamId: id,
  examType: 'ASSESSMENT',
  grade: 1,
  title: title,
  createDt: '20261116000000.000000',
  questions: const [],
);

void main() {
  late LingoProvider lingo;
  setUp(() => lingo = LingoProvider());
  tearDown(() => lingo.dispose());

  Future<void> pump(
    WidgetTester tester,
    List<GeneratedExam> items, {
    bool loading = false,
    String? error,
    bool reducedMotion = false,
  }) => tester.pumpWidget(
    LingoScope(
      lingo: lingo,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(disableAnimations: reducedMotion),
            child: SingleChildScrollView(
              child: HomeAssessmentList(
                assessments: items,
                activeAssessment: null,
                isLoading: loading,
                isOpeningActiveAssessment: false,
                errorMessage: error,
                onOpenExam: (_) {},
                onResumeExam: () {},
                onRetry: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Finder card(int id) => find.byWidgetPredicate(
    (widget) =>
        widget is AssessmentResultListItemCard && widget.exam.userExamId == id,
  );

  testWidgets(
    'only initial load uses skeleton; refresh and errors retain data',
    (tester) async {
      await pump(tester, [], loading: true);
      expect(find.byType(ParentAssessmentListSkeleton), findsOneWidget);
      await pump(tester, [exam(1), exam(2)]);
      await tester.pumpAndSettle();
      final top = tester.getTopLeft(card(2)).dy;
      await pump(tester, [exam(1), exam(2)], loading: true);
      expect(find.byType(ParentAssessmentListSkeleton), findsNothing);
      expect(card(1), findsOneWidget);
      expect(tester.getTopLeft(card(2)).dy, top);
      await pump(tester, [exam(1), exam(2)], error: 'Offline');
      expect(card(1), findsOneWidget);
      expect(tester.getTopLeft(card(2)).dy, top);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('new exam expands space smoothly; identical IDs do not replay', (
    tester,
  ) async {
    await pump(tester, [exam(1), exam(2)]);
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(card(1)).dy;
    await pump(tester, [exam(3), exam(1), exam(2)]);
    await tester.pump(const Duration(milliseconds: 80));
    final during = tester.getTopLeft(card(1)).dy;
    await tester.pumpAndSettle();
    final after = tester.getTopLeft(card(1)).dy;
    expect(during, greaterThan(before));
    expect(during, lessThan(after));
    expect(card(3), findsOneWidget);
    await pump(tester, [exam(3, title: 'Updated'), exam(1), exam(2)]);
    expect(tester.getTopLeft(card(1)).dy, after);
    expect(
      tester.widget<AssessmentResultListItemCard>(card(3)).exam.title,
      'Updated',
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'empty loaded list stays visible on refresh and supports insert/remove',
    (tester) async {
      await pump(tester, []);
      await pump(tester, [], loading: true);
      expect(find.byType(ParentAssessmentListSkeleton), findsNothing);
      await pump(tester, [exam(1)], reducedMotion: true);
      await tester.pumpAndSettle();
      expect(card(1), findsOneWidget);
      await pump(tester, [], reducedMotion: true);
      await tester.pumpAndSettle();
      expect(card(1), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
