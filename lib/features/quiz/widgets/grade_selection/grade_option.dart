part of '../../presentation/grade_selection_screen.dart';

class _GradeOption {
  const _GradeOption(this.number, this.label, {this.displayOrder = 0});

  factory _GradeOption.fromGradeModel(GradeModel grade) {
    final label = grade.label?.trim() ?? '';
    return _GradeOption(
      _gradeNumberFromLabel(label),
      label,
      displayOrder: grade.displayOrder ?? 0,
    );
  }

  final String? number;
  final String label;
  final int displayOrder;
}
