import 'package:flutter/material.dart';
import 'package:numi/features/home/parent/assessment/models/parent_assessment_entry.dart';
import 'package:numi/features/home/parent/assessment/widgets/parent_assessment_chart_painter.dart';

class ParentAssessmentProgressChart extends StatelessWidget {
  const ParentAssessmentProgressChart({
    super.key,
    required this.entries,
    required this.scale,
  });

  final List<ParentAssessmentEntry> entries;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: const Color(0xFFD7D7D7)),
      ),
      padding: EdgeInsets.fromLTRB(5 * scale, 7 * scale, 7 * scale, 4 * scale),
      child: CustomPaint(
        painter: ParentAssessmentChartPainter(entries: entries, scale: scale),
        child: const SizedBox.expand(),
      ),
    );
  }
}
