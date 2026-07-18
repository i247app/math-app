import 'package:flutter/material.dart';
import 'package:numi/features/quiz/models/parent_assessment_entry.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_chart_painter.dart';

class ParentAssessmentProgressChart extends StatelessWidget {
  const ParentAssessmentProgressChart({super.key, required this.entries});

  final List<ParentAssessmentEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD7D7D7)),
      ),
      padding: const EdgeInsets.fromLTRB(5, 7, 7, 4),
      child: CustomPaint(
        painter: ParentAssessmentChartPainter(entries: entries),
        child: const SizedBox.expand(),
      ),
    );
  }
}
