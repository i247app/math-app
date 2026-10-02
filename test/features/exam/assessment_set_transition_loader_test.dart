import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_set_transition_loader.dart';

void main() {
  const scenes = [
    (
      AssessmentSetTransitionKind.downGrade,
      'set-transition-stepping-stones',
      'One step at a time.',
    ),
    (
      AssessmentSetTransitionKind.stayGrade,
      'set-transition-puzzle',
      'That was a bit tricky, right?',
    ),
    (
      AssessmentSetTransitionKind.grow,
      'set-transition-sprout',
      'Every try helps you grow.',
    ),
    (
      AssessmentSetTransitionKind.trophy,
      'grade-up-trophy',
      'You are doing good',
    ),
  ];
  for (final (kind, artKey, title) in scenes) {
    testWidgets('$kind loops inside scrollable content with large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppThemeColors.light]),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: ListView(
                children: [AssessmentSetTransitionLoader(kind: kind)],
              ),
            ),
          ),
        ),
      );
      for (final duration in [
        const Duration(milliseconds: 400),
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 650),
        const Duration(milliseconds: 300),
        const Duration(milliseconds: 800),
      ]) {
        await tester.pump(duration);
        expect(tester.takeException(), isNull);
      }
      expect(find.byKey(ValueKey(artKey)), findsOneWidget);
      expect(find.text(title, findRichText: true), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);
      final textFade = find.byKey(const ValueKey('set-transition-message'));
      expect(tester.widget<FadeTransition>(textFade).opacity.value, 1);
      // More than two cycles later, the artwork is still running while the
      // message stays visible instead of fading in again with each replay.
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.hasRunningAnimations, isTrue);
      expect(tester.widget<FadeTransition>(textFade).opacity.value, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$kind shows its final state with reduced motion and dark gray background',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark().copyWith(
              extensions: const [AppThemeColors.dark],
            ),
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Scaffold(body: AssessmentSetTransitionLoader(kind: kind)),
            ),
          ),
        );
        await tester.pump();
        expect(tester.hasRunningAnimations, isFalse);
        expect(find.text(title, findRichText: true), findsOneWidget);
        expect(
          tester
              .widget<FadeTransition>(
                find.byKey(const ValueKey('set-transition-message')),
              )
              .opacity
              .value,
          1,
        );
        final background = tester.widget<ColoredBox>(
          find.descendant(
            of: find.byType(AssessmentSetTransitionLoader),
            matching: find.byType(ColoredBox),
          ),
        );
        expect(background.color, const Color(0xFF252525));
        final artFade = find.byKey(const ValueKey('set-transition-art-fade'));
        expect(tester.widget<FadeTransition>(artFade).opacity.value, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
