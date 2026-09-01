import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/quiz/application/read_models/parent_assessment_entry.dart';
import 'package:numi/features/quiz/presentation/widgets/parent_assessment/parent_assessment_chart_painter.dart';

class ParentAssessmentProgressChart extends StatelessWidget {
  const ParentAssessmentProgressChart({
    super.key,
    required this.entries,
    this.onTap,
  });

  final List<ParentAssessmentEntry> entries;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: context.getText(AppKeys.learningProgressTitle),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
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
        ),
      ),
    );
  }
}
