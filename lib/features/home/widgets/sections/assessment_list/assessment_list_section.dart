import 'package:flutter/material.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_card.dart';

typedef AssessmentListItemWrapper =
    Widget Function(Widget child, int index, int itemCount);

class AssessmentListSection extends StatelessWidget {
  const AssessmentListSection({
    super.key,
    required this.assessments,
    required this.onAssessmentTap,
    this.maxVisibleItems = 2,
    this.spacing = 8,
    this.itemWrapper,
  });

  final List<GeneratedQuiz> assessments;
  final ValueChanged<GeneratedQuiz> onAssessmentTap;
  final int maxVisibleItems;
  final double spacing;
  final AssessmentListItemWrapper? itemWrapper;

  @override
  Widget build(BuildContext context) {
    final visibleAssessments = assessments
        .take(maxVisibleItems)
        .toList(growable: false);

    return Column(
      spacing: spacing,
      children: [
        for (final entry in visibleAssessments.indexed)
          _wrapItem(
            AssessmentResultListItemCard(
              quiz: entry.$2,
              onTap: () => onAssessmentTap(entry.$2),
            ),
            entry.$1,
            visibleAssessments.length,
          ),
      ],
    );
  }

  Widget _wrapItem(Widget child, int index, int itemCount) {
    return itemWrapper?.call(child, index, itemCount) ?? child;
  }
}
