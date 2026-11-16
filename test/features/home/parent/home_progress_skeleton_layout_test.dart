import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_grade_ribbon.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/home/widgets/parent/home_progress_skeleton.dart';

void main() {
  for (final width in [280.0, 430.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets(
        'progress placeholder matches loaded layout at $width / $scale',
        (tester) async {
          final lingo = LingoProvider();
          addTearDown(lingo.dispose);
          Future<void> pump(bool loading) => tester.pumpWidget(
            LingoScope(
              lingo: lingo,
              child: MaterialApp(
                theme: AppTheme.light(),
                home: Scaffold(
                  body: MediaQuery(
                    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: width,
                        child: Builder(
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (loading)
                                const HomeProgressSkeleton()
                              else ...[
                                const AssessmentGradeRibbon(currentGrade: 3),
                                const SizedBox(height: 18),
                                AssessmentProgressionChart(
                                  finalGrade: 3,
                                  chartHeight: 150,
                                  gradeTitle: context.getText(
                                    AppKeys.homeChartLevel,
                                  ),
                                  activityTitle: context.getText(
                                    AppKeys.homeChartActivity,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              const SizedBox(
                                key: ValueKey('actions'),
                                height: 60,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await pump(true);
          final top = tester
              .getTopLeft(find.byKey(const ValueKey('actions')))
              .dy;
          await pump(false);
          expect(
            tester.getTopLeft(find.byKey(const ValueKey('actions'))).dy,
            closeTo(top, 0.01),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
