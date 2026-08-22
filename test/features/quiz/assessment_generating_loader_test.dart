import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_generating_loader.dart';
import 'package:numi/features/quiz/widgets/assessment/numi_assessment_mascot_animation.dart';

void main() {
  testWidgets('mascot loading sequence renders every stage without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AssessmentGeneratingLoader(
            message: 'Để Numi tạo bài kiểm tra cho bạn nhé',
          ),
        ),
      ),
    );

    expect(find.byType(NumiAssessmentMascotAnimation), findsOneWidget);
    expect(find.text('Để Numi tạo bài kiểm tra cho bạn nhé'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));

    // A transition renders both neighboring poses simultaneously. The
    // controller interpolates their opacity and transforms on every vsync.
    expect(find.byType(Image), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    for (final duration in <Duration>[
      const Duration(milliseconds: 700),
      const Duration(milliseconds: 700),
      const Duration(milliseconds: 700),
      const Duration(milliseconds: 700),
    ]) {
      await tester.pump(duration);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('reduced motion displays a stable mascot state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: NumiAssessmentMascotAnimation()),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 4));

    expect(find.byType(NumiAssessmentMascotAnimation), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('idea bulb is centered above the enlarged mascot', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NumiAssessmentMascotAnimation())),
    );

    // 2600 ms lands in the hold portion of the idea stage.
    await tester.pump(const Duration(milliseconds: 2600));

    final bulbRect = tester.getRect(find.byIcon(Icons.lightbulb_rounded));
    final mascotRect = tester.getRect(
      find.byKey(const ValueKey('numi-sprite-pose-2')),
    );

    expect(bulbRect.center.dx, closeTo(mascotRect.center.dx, 0.5));
    expect(bulbRect.bottom, lessThanOrEqualTo(mascotRect.top));
    expect(mascotRect.width, closeTo(210, 0.5));
    expect(tester.takeException(), isNull);
  });
}
