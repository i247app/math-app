import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
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
      find.byKey(const ValueKey('placement-you-are-here')),
      findsOneWidget,
    );
    expect(find.text('Bạn đang ở'), findsOneWidget);
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

  testWidgets(
    'waits for stats, then shows four previous assessments and the new one',
    (tester) async {
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      final pendingStats = Completer<List<ExamStats>>();
      final statsService = _DelayedStatsExamService(pendingStats.future);

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
              examService: statsService,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('assessment-placement-stats-loading')),
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

      pendingStats.complete([
        for (var index = 0; index < 6; index++)
          ExamStats(
            correctNumber: 5,
            scorePercentage: 100,
            skippedNumber: 0,
            totalQuestions: 5,
            userExamId: 101 + index,
            grade: index,
            lastSubmittedDt: DateTime.utc(2026, 1, index + 1),
            status: 'COMPLETE',
          ),
      ]);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('assessment-placement-stats-loading')),
        findsNothing,
      );
      final chart = tester.widget<AssessmentProgressionChart>(
        find.byType(AssessmentProgressionChart),
      );
      expect(chart.previousGrades, [1, 2, 3, 4]);
      expect(chart.finalGrade, 5);
      expect(chart.firstTestNumber, 2);
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
    'loads exam stats from API and applies progression transition on chart',
    (tester) async {
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);

      final statsService = _MockStatsExamService()
        ..mockStats = [
          ExamStats(
            correctNumber: 8,
            scorePercentage: 80.0,
            skippedNumber: 0,
            totalQuestions: 10,
            userExamId: 900,
            grade: 3,
            lastSubmittedDt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

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
              examService: statsService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(statsService.requestedProfileId, 999);
      expect(statsService.requestedExamType, examTypeAssessment);
      expect(
        find.byKey(const ValueKey('placement-progression-chart')),
        findsOneWidget,
      );
      // Both previous grade (Lớp 3) and current grade (Lớp 2) badges are present in the transition
      expect(find.text('Lớp 3'), findsWidgets);
      expect(find.text('Lớp 2'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

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

class _MockStatsExamService implements ExamService {
  int? requestedProfileId;
  String? requestedExamType;
  List<ExamStats> mockStats = const <ExamStats>[];

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    requestedProfileId = profileId;
    requestedExamType = examType;
    return mockStats;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DelayedStatsExamService implements ExamService {
  const _DelayedStatsExamService(this.stats);

  final Future<List<ExamStats>> stats;

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) => stats;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
