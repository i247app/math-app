import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_card.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_load_error.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_load_state.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_option.dart';

class GradeGrid extends StatelessWidget {
  const GradeGrid({
    super.key,
    required this.grades,
    required this.selectedGradeLabel,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelected,
    required this.onRetry,
  });
  final List<GradeModel> grades;
  final String? selectedGradeLabel;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<GradeOption> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const GradeLoadState();
    }

    if (errorMessage != null) {
      return GradeLoadError(message: errorMessage!, onRetry: onRetry);
    }

    final loadedItems =
        grades
            .where((grade) {
              final label = grade.label?.trim();
              return label != null && label.isNotEmpty;
            })
            .map(GradeOption.fromGradeModel)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (loadedItems.isEmpty) {
      return GradeLoadError(
        message: context.getText(AppKeys.noGrades),
        onRetry: onRetry,
      );
    }

    final kindergarten = loadedItems
        .where((option) => option.isKindergarten)
        .firstOrNull;
    final items = <GradeOption>[
      kindergarten ??
          GradeOption(
            null,
            AppLanguageState.current == AppLanguage.vi
                ? 'Mẫu giáo'
                : 'Kindergarten',
            displayOrder: 0,
          ),
      ...loadedItems.where((option) => !option.isKindergarten),
    ].where((option) => option.iconAsset != null).take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final option = items[index];
        return GradeCard(
          option: option,
          isSelected: option.label == selectedGradeLabel,
          onSelected: () => onSelected(option),
        );
      },
    );
  }
}
