part of '../../presentation/grade_selection_screen.dart';

class _GradeGrid extends StatelessWidget {
  const _GradeGrid({
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
  final ValueChanged<_GradeOption> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _GradeLoadState(scale: scale);
    }

    if (errorMessage != null) {
      return _GradeLoadError(
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
            .map(_GradeOption.fromGradeModel)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (items.isEmpty) {
      return _GradeLoadError(
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
        return _GradeCard(
          option: option,
          scale: scale,
          isSelected: option.label == selectedGradeLabel,
          onSelected: () => onSelected(option),
        );
      },
    );
  }
}
