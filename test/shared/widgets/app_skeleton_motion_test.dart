import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_loading_content.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_loading_section.dart';

Widget _app(Widget child, {bool reduceMotion = true, bool dark = false}) =>
    MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: child),
      ),
    );

void main() {
  for (final dark in [false, true]) {
    for (final full in [false, true]) {
      testWidgets(
        'review skeleton is static with reduced motion, dark=$dark, full=$full',
        (tester) async {
          final child = full
              ? const ExamReviewLoadingContent()
              : const ExamReviewQuestionLoadingSection();
          await tester.pumpWidget(_app(child, dark: dark));
          await tester.pumpAndSettle();
          expect(find.byType(AppSkeletonLoader), findsOneWidget);
          expect(find.byType(AppSkeletonBlock), findsNWidgets(full ? 9 : 7));
          expect(find.byType(ShaderMask), findsNothing);
          final baseColor = dark
              ? AppThemeColors.dark.skeleton
              : AppThemeColors.light.skeleton;
          expect(
            tester
                .widgetList<AppSkeletonBlock>(find.byType(AppSkeletonBlock))
                .map((block) => block.color),
            everyElement(baseColor),
          );
          await tester.pump(const Duration(milliseconds: 700));
          expect(tester.binding.hasScheduledFrame, isFalse);
          expect(
            tester
                .widgetList<AppSkeletonBlock>(find.byType(AppSkeletonBlock))
                .map((block) => block.color),
            everyElement(baseColor),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'shared loader stops pulse and shimmer when motion preference changes and resumes',
    (tester) async {
      int builds = 0;
      Color? fill;
      final loader = AppSkeletonLoader(
        builder: (_, color) {
          builds++;
          fill = color;
          return AppSkeletonBlock(height: 80, radius: 12, color: color);
        },
      );
      await tester.pumpWidget(_app(loader, reduceMotion: false));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpWidget(_app(loader));
      await tester.pumpAndSettle();
      final stoppedBuilds = builds;
      expect(fill, AppThemeColors.light.skeleton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(builds, stoppedBuilds);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.byType(ShaderMask), findsNothing);
      await tester.pumpWidget(_app(loader, reduceMotion: false));
      await tester.pump(const Duration(milliseconds: 200));
      expect(builds, greaterThan(stoppedBuilds));
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpWidget(_app(const SizedBox()));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shared card stops its ticker with reduced motion and resumes', (
    tester,
  ) async {
    const card = AppSkeletonCard(
      child: AppSkeletonBlock(height: 80, radius: 12),
    );
    await tester.pumpWidget(_app(card, reduceMotion: false));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ShaderMask), findsOneWidget);
    await tester.pumpWidget(_app(card));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.byType(ShaderMask), findsNothing);
    await tester.pumpWidget(_app(card, reduceMotion: false));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpWidget(_app(const SizedBox()));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'full loading content uses one animation instead of per-block shimmer masks',
    (tester) async {
      await tester.pumpWidget(
        _app(const ExamReviewLoadingContent(), reduceMotion: false),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AppSkeletonLoader), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpWidget(_app(const SizedBox()));
      expect(tester.takeException(), isNull);
    },
  );
}
