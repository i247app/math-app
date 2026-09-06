import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/sections/assessment_list/home_assessment_result_card.dart';
import 'package:numi/features/quiz/models/quiz.dart';

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
    this.useCardShadow = false,
  });

  final List<GeneratedQuiz> assessments;
  final ValueChanged<GeneratedQuiz> onAssessmentTap;
  final int maxVisibleItems;
  final double spacing;
  final AssessmentListItemWrapper? itemWrapper;
  final bool useCardShadow;

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
            HomeAssessmentResultCard(
              quiz: entry.$2,
              onTap: () => onAssessmentTap(entry.$2),
              useCardShadow: useCardShadow,
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
