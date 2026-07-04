import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_number_from_label.dart';

class GradeOption {
  const GradeOption(this.number, this.label, {this.displayOrder = 0});

  factory GradeOption.fromGradeModel(GradeModel grade) {
    final label = grade.label?.trim() ?? '';
    return GradeOption(
      gradeNumberFromLabel(label),
      label,
      displayOrder: grade.displayOrder ?? 0,
    );
  }

  final String? number;
  final String label;
  final int displayOrder;
}
