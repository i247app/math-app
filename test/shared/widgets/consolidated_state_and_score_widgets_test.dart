import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/shared/widgets/parent_tasks/parent_task_score_ring.dart';
import 'package:numi/shared/widgets/app_state_panel.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';

void main() {
  testWidgets('AppStatePanel renders and forwards a custom action', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AppStatePanel(
            title: 'Nothing here',
            message: 'Try loading this section again.',
            visual: const Icon(Icons.cloud_off_rounded),
            action: OutlinedButton(
              onPressed: () => tapCount += 1,
              child: const Text('Reload'),
            ),
            visualTitleSpacing: 8,
            titleMessageSpacing: 4,
            messageActionSpacing: 10,
          ),
        ),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Try loading this section again.'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

    await tester.tap(find.text('Reload'));
    expect(tapCount, 1);
  });

  testWidgets('ScoreDisplayRing centralizes score text and progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      LingoScope(
        lingo: LingoProvider(),
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: ScoreDisplayRing(
              scoreText: '7.5/10',
              progress: 0.75,
              ringColor: Colors.orange,
              scoreColor: Colors.green,
            ),
          ),
        ),
      ),
    );

    final progressRing = tester.widget<ScoreProgressRing>(
      find.descendant(
        of: find.byType(ScoreDisplayRing),
        matching: find.byType(ScoreProgressRing),
      ),
    );
    final scoreText = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == '7.5/10',
      ),
    );

    expect(progressRing.progress, 0.75);
    expect(progressRing.color, Colors.orange);
    expect(progressRing.size, 150);
    expect(scoreText.text.toPlainText(), '7.5/10');
  });

  testWidgets('ParentTaskScoreRing delegates drawing to ScoreProgressRing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ParentTaskScoreRing(score: 7, color: Colors.teal)),
      ),
    );

    final ring = tester.widget<ScoreProgressRing>(
      find.byType(ScoreProgressRing),
    );
    expect(ring.progress, 0.7);
    expect(ring.size, 48);
    expect(ring.strokeWidth, 5);
    expect(find.text('7'), findsOneWidget);
  });
}
