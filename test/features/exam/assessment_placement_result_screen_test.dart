import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/assessment_placement_result_screen.dart';
import 'package:numi/features/exam/screens/assessment_result_screen.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/shared/layouts/page_header.dart';

void main() {
  testWidgets('bundles every placement celebration layer', (tester) async {
    const assets = [
      'assets/images/assessment-result-mascot.png',
      'assets/images/assessment-result-stars.png',
      'assets/images/assessment-result-numbers.png',
      'assets/images/assessment-result-blocks.png',
      'assets/images/assessment-result-checklist.png',
      'assets/images/assessment-result-pencil.png',
      'assets/images/grade-ribbon.png',
      'assets/images/grade-ribbon-en.png',
    ];

    for (final asset in assets) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });

  testWidgets('matches the focused placement result layout', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: const AssessmentPlacementResultScreen(
            grade: 0,
            correctAnswers: 5,
            totalQuestions: 8,
            examService: _UnusedExamService(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AssessmentPlacementResultScreen), findsOneWidget);
    expect(find.byType(AssessmentResultScreen), findsNothing);
    expect(find.byType(PageHeader), findsOneWidget);
    expect(find.text('Kết Quả'), findsOneWidget);
    expect(find.text('Trình độ'), findsOneWidget);
    expect(find.text('MẪU GIÁO'), findsOneWidget);
    expect(find.text('Chúc mừng!'), findsNothing);
    expect(find.text('Bạn đã trả lời đúng 5/8 câu hỏi'), findsNothing);
    expect(find.text('Xem chi tiết'), findsOneWidget);
    expect(find.text('Luyện tập'), findsOneWidget);
    final levelRect = tester.getRect(find.text('Trình độ'));
    final gradeRect = tester.getRect(
      find.byKey(const ValueKey('placement-grade')),
    );
    expect(gradeRect.top - levelRect.bottom, greaterThanOrEqualTo(16));
    expect(find.byKey(const ValueKey('placement-mascot')), findsOneWidget);
    final mascotImage = tester.widget<Image>(
      find.byKey(const ValueKey('placement-mascot-character')),
    );
    expect(mascotImage.image, isA<ResizeImage>());
    final mascotAsset = (mascotImage.image as ResizeImage).imageProvider;
    expect(
      mascotAsset,
      isA<AssetImage>().having(
        (image) => image.assetName,
        'assetName',
        'assets/images/assessment-result-mascot.png',
      ),
    );
    expect(
      find.byKey(const ValueKey('placement-decoration-stars')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('placement-decoration-numbers')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('placement-decoration-blocks')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('placement-decoration-checklist')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('placement-decoration-pencil')),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a numbered grade', (tester) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: const AssessmentPlacementResultScreen(
            grade: 3,
            correctAnswers: 12,
            totalQuestions: 16,
            examService: _UnusedExamService(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('LỚP 3'), findsOneWidget);
    expect(find.text('Xem chi tiết'), findsOneWidget);
    expect(find.text('Luyện tập'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens details from the outlined action', (tester) async {
    var didOpenDetails = false;
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: AssessmentPlacementResultScreen(
            grade: 1,
            correctAnswers: 6,
            totalQuestions: 10,
            examService: const _UnusedExamService(),
            onViewDetails: () => didOpenDetails = true,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('placement-view-details')));
    await tester.pump();

    expect(didOpenDetails, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the same normalized weak topics used by practice', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: const AssessmentPlacementResultScreen(
            grade: 2,
            correctAnswers: 6,
            totalQuestions: 10,
            examService: _UnusedExamService(),
            practiceWeakTopics: <ExamPracticeTopic>[
              ExamPracticeTopic(
                topic: ' Phép trừ có nhớ ',
                answered: 3,
                wrong: 2,
              ),
              ExamPracticeTopic(topic: 'Toán đố', answered: 2, wrong: 1),
              ExamPracticeTopic(
                topic: 'Phép trừ có nhớ',
                answered: 1,
                wrong: 1,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('placement-weak-topics')), findsOneWidget);
    expect(find.text('Luyện Phép trừ có nhớ và Toán đố'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('practice again generates PRACTICE at the placement grade', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final service = _RecordingPracticeService();
    GeneratedExam? generatedExam;
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: AssessmentPlacementResultScreen(
            grade: 4,
            correctAnswers: 6,
            totalQuestions: 10,
            examService: service,
            profileId: 21,
            userExamId: 99,
            onTestAgainGenerated: (exam) => generatedExam = exam,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('placement-practice-again')));
    await tester.pump();

    expect(service.requestedExamType, examTypePractice);
    expect(service.requestedGradeLabel, 'Lớp 4');
    expect(service.requestedProfileId, 21);
    expect(service.requestedUserExamId, 99);
    expect(generatedExam?.examType, examTypePractice);
    expect(generatedExam?.grade, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing the result does not update assessment status', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final service = _RecordingPracticeService();
    var didClose = false;
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: AssessmentPlacementResultScreen(
            grade: 2,
            correctAnswers: 6,
            totalQuestions: 10,
            examService: service,
            profileId: 21,
            userExamId: 99,
            onBack: () => didClose = true,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('placement-result-close')));
    await tester.pump();

    expect(service.completedUserExamId, isNull);
    expect(service.completedStatus, isNull);
    expect(didClose, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English grade and actions stay inside their bounds', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FlutterSecureStorage.setMockInitialValues(<String, String>{});

    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: const AssessmentPlacementResultScreen(
            grade: 0,
            correctAnswers: 5,
            totalQuestions: 8,
            examService: _UnusedExamService(),
          ),
        ),
      ),
    );
    await tester.pump();

    final vietnameseMascotRect = tester.getRect(
      find.byKey(const ValueKey('placement-mascot')),
    );
    final vietnameseGradeContainerRect = tester.getRect(
      find.byKey(const ValueKey('placement-grade-container')),
    );
    final vietnameseDetailsButtonRect = tester.getRect(
      find.byKey(const ValueKey('placement-view-details')),
    );
    final vietnamesePracticeButtonRect = tester.getRect(
      find.byKey(const ValueKey('placement-practice-again')),
    );

    await lingo.setLanguage(AppLanguage.en);
    await tester.pump();

    final englishRibbonImage = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const ValueKey('placement-grade-ribbon')),
        matching: find.byType(Image),
      ),
    );
    expect(
      englishRibbonImage.image,
      isA<AssetImage>().having(
        (image) => image.assetName,
        'assetName',
        'assets/images/grade-ribbon-en.png',
      ),
    );

    final gradeRect = tester.getRect(
      find.byKey(const ValueKey('placement-grade')),
    );
    expect(gradeRect.left, greaterThanOrEqualTo(16));
    expect(gradeRect.right, lessThanOrEqualTo(344));
    expect(gradeRect.height, lessThan(60));

    final practiceButtonRect = tester.getRect(
      find.byKey(const ValueKey('placement-practice-again')),
    );
    final practiceTextRect = tester.getRect(find.text('Practice'));
    expect(practiceTextRect.left, greaterThan(practiceButtonRect.left + 32));
    expect(practiceTextRect.right, lessThan(practiceButtonRect.right - 8));
    expect(
      tester.getRect(find.byKey(const ValueKey('placement-mascot'))),
      vietnameseMascotRect,
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('placement-grade-container'))),
      vietnameseGradeContainerRect,
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('placement-view-details'))),
      vietnameseDetailsButtonRect,
    );
    expect(practiceButtonRect, vietnamesePracticeButtonRect);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders grade ribbon and progression chart for assessed grade', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: const AssessmentPlacementResultScreen(
            grade: 3,
            correctAnswers: 5,
            totalQuestions: 5,
            examService: _UnusedExamService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('placement-grade-ribbon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('placement-current-grade-marker')),
      findsOneWidget,
    );
    expect(find.text('Bạn đang ở'), findsNothing);
    final marker = find.byKey(const ValueKey('placement-current-grade-marker'));
    expect(
      tester
          .widget<ColoredBox>(
            find.descendant(of: marker, matching: find.byType(ColoredBox)),
          )
          .color,
      AppColors.red,
    );
    final ribbonRect = tester.getRect(
      find.byKey(const ValueKey('placement-grade-ribbon')),
    );
    expect(
      tester.getCenter(marker).dx,
      closeTo(ribbonRect.left + ribbonRect.width * 0.557, 1),
    );
    expect(
      find.byKey(const ValueKey('placement-progression-chart')),
      findsOneWidget,
    );
    expect(find.text('Bài 1'), findsOneWidget);
    expect(find.text('Bài 5'), findsNothing);
    expect(find.text('M.Giáo'), findsOneWidget);
    final ribbonImage = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const ValueKey('placement-grade-ribbon')),
        matching: find.byType(Image),
      ),
    );
    expect(
      ribbonImage.image,
      isA<AssetImage>().having(
        (image) => image.assetName,
        'assetName',
        'assets/images/grade-ribbon.png',
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('GRADE result keeps ribbon but does not load or show chart', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    final progressService = _MockProgressExamService();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: AssessmentPlacementResultScreen(
            grade: 3,
            correctAnswers: 5,
            totalQuestions: 5,
            examType: examTypeGrade,
            profileId: 999,
            previousGrade: 2,
            examService: progressService,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(progressService.requestedProfileId, isNull);
    expect(
      find.byKey(const ValueKey('assessment-placement-progress-loading')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('placement-grade-ribbon')),
      findsOneWidget,
    );
    expect(find.byType(AssessmentProgressionChart), findsNothing);
    expect(
      find.byKey(const ValueKey('placement-view-details')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'waits for journey progress, then shows four previous assessments and the new one',
    (tester) async {
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      final pendingProgress = Completer<ExamProgressResponse>();
      final progressService = _DelayedProgressExamService(
        pendingProgress.future,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: LingoScope(
            lingo: lingo,
            child: AssessmentPlacementResultScreen(
              grade: 5,
              correctAnswers: 5,
              totalQuestions: 5,
              profileId: 999,
              userExamId: 106,
              examService: progressService,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('assessment-placement-progress-loading')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('assessment-placement-ribbon-skeleton')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('assessment-placement-chart-skeleton')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('placement-progression-chart')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('placement-grade-ribbon')),
        findsNothing,
      );

      pendingProgress.complete(
        _progressResponse([
          for (var index = 0; index < 6; index++)
            _progressPoint(
              examId: 101 + index,
              grade: index,
              sequence: index + 1,
            ),
        ]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final fade = tester.widget<Opacity>(
        find.byKey(const ValueKey('assessment-placement-history-content')),
      );
      expect(fade.opacity, greaterThan(0));
      expect(fade.opacity, lessThan(1));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('assessment-placement-progress-loading')),
        findsNothing,
      );
      final chart = tester.widget<AssessmentProgressionChart>(
        find.byType(AssessmentProgressionChart),
      );
      expect(chart.previousGrades, [1, 2, 3, 4]);
      expect(chart.finalGrade, 5);
      expect(chart.firstTestNumber, 2);
      expect(chart.testNumbers, [2, 3, 4, 5, 6]);
      expect(find.text('Bài 2'), findsOneWidget);
      expect(find.text('Bài 6'), findsOneWidget);
      expect(find.text('Bài 1'), findsNothing);
      expect(
        find.byKey(const ValueKey('placement-grade-ribbon')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'loads journey progress from API and applies progression transition on chart',
    (tester) async {
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);

      final progressService = _MockProgressExamService()
        ..mockProgress = _progressResponse([
          _progressPoint(examId: 900, grade: 3, sequence: 4),
        ]);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: LingoScope(
            lingo: lingo,
            child: AssessmentPlacementResultScreen(
              grade: 2,
              correctAnswers: 4,
              totalQuestions: 5,
              profileId: 999,
              userExamId: 901,
              examService: progressService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(progressService.requestedProfileId, 999);
      expect(progressService.requestedExamType, examTypeAssessment);
      expect(progressService.requestedToDt, isNotNull);
      expect(
        progressService.requestedToDt!.difference(
          progressService.requestedFromDt!,
        ),
        const Duration(days: 7),
      );
      expect(
        find.byKey(const ValueKey('placement-progression-chart')),
        findsOneWidget,
      );
      // Both previous grade (Lớp 3) and current grade (Lớp 2) badges are present in the transition
      expect(find.text('Lớp 3'), findsWidgets);
      expect(find.text('Lớp 2'), findsWidgets);
      final chart = tester.widget<AssessmentProgressionChart>(
        find.byType(AssessmentProgressionChart),
      );
      expect(chart.testNumbers, [4, 5]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('orders chart points by API sequence up to the current exam', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    final progressService = _MockProgressExamService()
      ..mockProgress = _progressResponse([
        _progressPoint(examId: 201, grade: 2, sequence: 4),
        _progressPoint(examId: 198, grade: 0, sequence: 1),
        _progressPoint(examId: 202, grade: 3, sequence: 5),
        _progressPoint(examId: 199, grade: 1, sequence: 2),
      ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: AssessmentPlacementResultScreen(
            grade: 2,
            correctAnswers: 5,
            totalQuestions: 5,
            profileId: 999,
            userExamId: 201,
            examService: progressService,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chart = tester.widget<AssessmentProgressionChart>(
      find.byType(AssessmentProgressionChart),
    );
    expect(chart.previousGrades, [0, 1]);
    expect(chart.finalGrade, 2);
    expect(chart.testNumbers, [1, 2, 4]);
    expect(find.text('Bài 5'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'animates line drawing jump from previous grade down to final grade',
    (tester) async {
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: LingoScope(
            lingo: lingo,
            child: const AssessmentPlacementResultScreen(
              grade: 2,
              previousGrade: 3,
              correctAnswers: 4,
              totalQuestions: 5,
              examService: _UnusedExamService(),
            ),
          ),
        ),
      );

      // Initial frame
      await tester.pump();
      expect(
        find.byKey(const ValueKey('placement-progression-chart')),
        findsOneWidget,
      );

      // Midway through animation (drawing across points)
      await tester.pump(const Duration(milliseconds: 700));

      // Finish animation
      await tester.pumpAndSettle();
      expect(find.text('Lớp 3'), findsWidgets);
      expect(find.text('Lớp 2'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('chart shows only the final grade badge, not a previous badge', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    await lingo.setLanguage(AppLanguage.en);

    await tester.pumpWidget(
      MaterialApp(
        home: LingoScope(
          lingo: lingo,
          child: const Scaffold(
            body: Center(
              child: AssessmentProgressionChart(
                finalGrade: 1,
                previousGrades: <int>[0, 1, 0],
                animate: false,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grade 0'), findsOneWidget);
    expect(find.text('Grade 1'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('English grade-zero chart shows Grade 0 on axis and badge', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    await lingo.setLanguage(AppLanguage.en);

    await tester.pumpWidget(
      MaterialApp(
        home: LingoScope(
          lingo: lingo,
          child: const Scaffold(
            body: Center(
              child: AssessmentProgressionChart(finalGrade: 0, animate: false),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grade 0'), findsNWidgets(2));
    expect(find.text('Kinder.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single assessment aligns its label and badge with the y axis', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LingoScope(
          lingo: lingo,
          child: const Scaffold(
            body: Center(
              child: AssessmentProgressionChart(finalGrade: 5, animate: false),
            ),
          ),
        ),
      ),
    );

    final plotLeft = tester
        .getTopLeft(find.byKey(const ValueKey('placement-progression-plot')))
        .dx;
    final badgeLeft = tester
        .getTopLeft(
          find.byKey(const ValueKey('placement-progression-final-badge')),
        )
        .dx;
    final labelCenter = tester.getCenter(find.text('Bài 1')).dx;

    expect(badgeLeft, inInclusiveRange(plotLeft, plotLeft + 16));
    expect(labelCenter, closeTo(plotLeft, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('test labels are centered under their chart points', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LingoScope(
          lingo: lingo,
          child: const Scaffold(
            body: Center(
              child: AssessmentProgressionChart(
                finalGrade: 5,
                previousGrades: <int>[0, 2],
                testNumbers: <int>[2, 4, 7],
                animate: false,
              ),
            ),
          ),
        ),
      ),
    );

    final plot = tester.getRect(
      find.byKey(const ValueKey('placement-progression-plot')),
    );
    expect(tester.getCenter(find.text('Bài 2')).dx, closeTo(plot.left, 1));
    expect(
      tester.getCenter(find.text('Bài 4')).dx,
      closeTo(plot.left + (plot.width - 28) / 2, 1),
    );
    expect(
      tester.getCenter(find.text('Bài 7')).dx,
      closeTo(plot.right - 28, 1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('last test label stays inside a narrow chart', (tester) async {
    tester.view.physicalSize = const Size(264, 190);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    await lingo.setLanguage(AppLanguage.en);
    await tester.pumpWidget(
      MaterialApp(
        home: LingoScope(
          lingo: lingo,
          child: const Scaffold(
            body: Center(
              child: AssessmentProgressionChart(
                finalGrade: 1,
                previousGrades: <int>[0],
                testNumbers: <int>[1, 2],
                chartHeight: 120,
                animate: false,
              ),
            ),
          ),
        ),
      ),
    );

    final chart = tester.getRect(
      find.byKey(const ValueKey('placement-progression-chart')),
    );
    final plot = tester.getRect(
      find.byKey(const ValueKey('placement-progression-plot')),
    );
    final lastLabel = tester.getRect(find.text('Test 2'));
    expect(tester.getCenter(find.text('Test 1')).dx, closeTo(plot.left, 1));
    expect(lastLabel.center.dx, closeTo(plot.right - 28, 1));
    expect(lastLabel.right, lessThan(chart.right));
    expect(tester.takeException(), isNull);
  });
}

class _UnusedExamService implements ExamService {
  const _UnusedExamService();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingPracticeService implements ExamService {
  String? requestedExamType;
  String? requestedGradeLabel;
  int? requestedProfileId;
  int? requestedUserExamId;
  int? completedUserExamId;
  String? completedStatus;

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) async {
    requestedExamType = examType;
    requestedGradeLabel = gradeLabel;
    requestedProfileId = profileId;
    requestedUserExamId = userExamId;
    return const GeneratedExam(
      examId: 401,
      examType: examTypePractice,
      grade: 4,
      questions: <ExamQuestion>[
        ExamQuestion(
          questionName: '10 + 5 = ?',
          questionNumber: 1,
          rightAnswer: 'A',
          answers: <ExamAnswer>[
            ExamAnswer(label: 'A', content: '15'),
            ExamAnswer(label: 'B', content: '14'),
          ],
        ),
      ],
    );
  }

  @override
  Future<void> updateUserExamStatus({
    required int userExamId,
    required String status,
    int? profileId,
  }) async {
    completedUserExamId = userExamId;
    completedStatus = status;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockProgressExamService implements ExamService {
  int? requestedProfileId;
  String? requestedExamType;
  DateTime? requestedFromDt;
  DateTime? requestedToDt;
  ExamProgressResponse? mockProgress;

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
    String examType = examTypeAssessment,
  }) async {
    requestedProfileId = profileId;
    requestedExamType = examType;
    requestedFromDt = fromDt;
    requestedToDt = toDt;
    return mockProgress ?? _progressResponse(const <ExamProgressPoint>[]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DelayedProgressExamService implements ExamService {
  const _DelayedProgressExamService(this.progress);

  final Future<ExamProgressResponse> progress;

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
    String examType = examTypeAssessment,
  }) => progress;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ExamProgressResponse _progressResponse(List<ExamProgressPoint> points) =>
    ExamProgressResponse(mstatus: 200, series: points);

ExamProgressPoint _progressPoint({
  required int examId,
  required int grade,
  required int sequence,
  String status = 'COMPLETE',
}) => ExamProgressPoint(
  completedDt: DateTime.utc(2026, 1, sequence),
  correctNumber: 5,
  examId: examId,
  score: 10,
  scorePct: 100,
  sequence: sequence,
  totalQuestions: 5,
  grade: grade,
  status: status,
);
