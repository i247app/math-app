import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/screens/assessment_placement_result_screen.dart';
import 'package:numi/features/exam/screens/assessment_result_screen.dart';
import 'package:numi/shared/layouts/page_header.dart';

void main() {
  testWidgets('bundles the placement mascot asset', (tester) async {
    final data = await rootBundle.load(
      'assets/images/assessment-placement-mascot.png',
    );

    expect(data.lengthInBytes, greaterThan(0));
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
    expect(find.text('Bạn đạt trình độ'), findsOneWidget);
    expect(find.text('MẪU GIÁO'), findsOneWidget);
    expect(find.text('Chúc mừng!'), findsNothing);
    expect(find.text('Bạn đã trả lời đúng 5/8 câu hỏi'), findsNothing);
    expect(find.text('Xem chi tiết'), findsOneWidget);
    expect(find.text('Luyện tập lại'), findsOneWidget);
    expect(find.byKey(const ValueKey('placement-mascot')), findsOneWidget);
    final mascotImage = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const ValueKey('placement-mascot')),
        matching: find.byType(Image),
      ),
    );
    expect(mascotImage.image, isA<ResizeImage>());
    final mascotAsset = (mascotImage.image as ResizeImage).imageProvider;
    expect(
      mascotAsset,
      isA<AssetImage>().having(
        (image) => image.assetName,
        'assetName',
        'assets/images/assessment-placement-mascot.png',
      ),
    );
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
    expect(find.text('Luyện tập lại'), findsOneWidget);
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
    final practiceTextRect = tester.getRect(find.text('Practice again'));
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
}

class _UnusedExamService implements ExamService {
  const _UnusedExamService();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
