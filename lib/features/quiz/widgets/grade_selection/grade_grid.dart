import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_card.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_load_error.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_load_state.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_option.dart';

class GradeGrid extends StatelessWidget {
  const GradeGrid({
    super.key,
    required this.scale,
    required this.grades,
    required this.selectedGradeLabel,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelected,
    required this.onRetry,
  });

  final double scale;
  final List<GradeModel> grades;
  final String? selectedGradeLabel;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<GradeOption> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GradeLoadState(scale: scale);
    }

    if (errorMessage != null) {
      return GradeLoadError(
        scale: scale,
        message: errorMessage!,
        onRetry: onRetry,
      );
    }

    final items =
        grades
            .where((grade) {
              final label = grade.label?.trim();
              return label != null && label.isNotEmpty;
            })
            .map(GradeOption.fromGradeModel)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (items.isEmpty) {
      return GradeLoadError(
        scale: scale,
        message: context.getText(AppKeys.noGrades),
        onRetry: onRetry,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12 * scale,
        crossAxisSpacing: 12 * scale,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final option = items[index];
        return GradeCard(
          option: option,
          scale: scale,
          isSelected: option.label == selectedGradeLabel,
          onSelected: () => onSelected(option),
        );
      },
    );
  }
}
