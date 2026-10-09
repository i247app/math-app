import 'package:numi/features/exam/models/assessment_progress_chart_data.dart';

class PlacementResultState {
  const PlacementResultState({
    required this.chart,
    required this.progressResolved,
    this.isGenerating = false,
  });

  final AssessmentProgressChartData chart;
  final bool progressResolved;
  final bool isGenerating;

  int get grade => chart.finalGrade;

  PlacementResultState copyWith({
    AssessmentProgressChartData? chart,
    bool? progressResolved,
    bool? isGenerating,
  }) => PlacementResultState(
    chart: chart ?? this.chart,
    progressResolved: progressResolved ?? this.progressResolved,
    isGenerating: isGenerating ?? this.isGenerating,
  );
}
