import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';

void main() {
  testWidgets('empty history has no dot but a real grade zero does', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    var hasResults = false;
    late StateSetter update;
    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return AssessmentProgressionChart(
                  finalGrade: 0,
                  showDataPoints: hasResults,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final plot = find.byKey(const ValueKey('placement-progression-plot'));
    expect(plot, paintsExactlyCountTimes(#drawCircle, 0));
    expect(plot, paintsExactlyCountTimes(#drawLine, 6));

    update(() => hasResults = true);
    await tester.pumpAndSettle();
    // A completed grade-zero assessment draws its dot and highlight at K.
    expect(plot, paintsExactlyCountTimes(#drawCircle, 2));
    expect(find.text('K'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
