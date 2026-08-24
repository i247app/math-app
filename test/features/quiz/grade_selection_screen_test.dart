import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/errors/quiz_exception.dart';
import 'package:numi/features/quiz/presentation/screens/grade_selection_screen.dart';
import 'package:numi/shared/layouts/page_header.dart';

class _UnusedGradeService implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) {
    throw StateError('The initial grade list should be used by this test.');
  }
}

class _FailingQuizService implements QuizService {
  final List<String?> requestedGradeLabels = <String?>[];

  @override
  Future<GeneratedQuiz> generateAssessmentQuiz({
    String purpose = quizPurposeAssessment,
    String typeOfQuiz = quizTypeGeneral,
    String? gradeLabel,
    int? previousQuizId,
    List<String>? chapters,
    int? profileId,
  }) {
    requestedGradeLabels.add(gradeLabel);
    throw const QuizException('Generation failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const grades = <GradeModel>[
    GradeModel(id: 1, label: 'Lớp 1', displayOrder: 1),
    GradeModel(id: 2, label: 'Lớp 2', displayOrder: 2),
    GradeModel(id: 3, label: 'Lớp 3', displayOrder: 3),
    GradeModel(id: 4, label: 'Lớp 4', displayOrder: 4),
    GradeModel(id: 5, label: 'Lớp 5', displayOrder: 5),
  ];

  testWidgets(
    'uses the six grade icons, PageHeader, and plain continue label',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final previousLanguage = AppLanguageState.current;
      AppLanguageState.current = AppLanguage.vi;
      addTearDown(() => AppLanguageState.current = previousLanguage);
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: LingoScope(
            lingo: lingo,
            child: GradeSelectionScreen(
              initialGrades: grades,
              gradeService: _UnusedGradeService(),
              quizPurpose: quizPurposePractice,
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PageHeader), findsOneWidget);
      expect(find.text('Chọn lớp'), findsOneWidget);
      expect(find.text('Tiếp tục'), findsOneWidget);
      expect(find.textContaining('→'), findsNothing);
      expect(find.text('BỎ QUA'), findsNothing);

      const expectedAssets = <String>[
        'assets/icons/mau_giao.svg',
        'assets/icons/1.svg',
        'assets/icons/2.svg',
        'assets/icons/3.svg',
        'assets/icons/4.svg',
        'assets/icons/5.svg',
      ];
      expect(find.byType(SvgPicture), findsOneWidget);
      for (final asset in expectedAssets) {
        expect(find.byKey(ValueKey('grade-card-$asset')), findsOneWidget);
        expect(find.byKey(ValueKey('grade-icon-$asset')), findsOneWidget);
        expect(find.byKey(ValueKey('grade-icon-image-$asset')), findsOneWidget);
        expect(
          find.byKey(ValueKey('grade-icon-fallback-$asset')),
          findsNothing,
        );
      }
      expect(
        tester
            .getTopLeft(
              find.byKey(
                const ValueKey('grade-card-assets/icons/mau_giao.svg'),
              ),
            )
            .dx,
        closeTo(38, 1),
      );

      final continueButtonFinder = find.ancestor(
        of: find.text('Tiếp tục'),
        matching: find.byType(TextButton),
      );
      final continueButton = tester.widget<TextButton>(continueButtonFinder);
      final buttonShape = continueButton.style?.shape?.resolve({});
      expect(buttonShape, isA<RoundedRectangleBorder>());
      expect(
        (buttonShape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(18),
      );
      expect(
        tester.view.physicalSize.height -
            tester.getBottomRight(continueButtonFinder).dy,
        closeTo(96, 1),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'shows a localized notice after assessment generation automatically fails',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final previousLanguage = AppLanguageState.current;
      AppLanguageState.current = AppLanguage.vi;
      addTearDown(() => AppLanguageState.current = previousLanguage);
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);

      final quizService = _FailingQuizService();
      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
            ),
            home: GradeSelectionScreen(
              initialGrades: grades,
              gradeService: _UnusedGradeService(),
              quizService: quizService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('grade-card-assets/icons/1.svg')),
      );
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      expect(find.text('Tạo bài đánh giá thất bại.'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('generate-failed-notice')),
        findsOneWidget,
      );
      expect(quizService.requestedGradeLabels, <String?>['Lớp 1']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'generates an assessment with an empty grade when no grade is selected',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final previousLanguage = AppLanguageState.current;
      AppLanguageState.current = AppLanguage.vi;
      addTearDown(() => AppLanguageState.current = previousLanguage);
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      final quizService = _FailingQuizService();

      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
            ),
            home: GradeSelectionScreen(
              initialGrades: grades,
              gradeService: _UnusedGradeService(),
              quizService: quizService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      expect(quizService.requestedGradeLabels, <String?>['']);
      expect(tester.takeException(), isNull);
    },
  );
}
