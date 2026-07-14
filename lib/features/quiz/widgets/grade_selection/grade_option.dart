import 'package:numi/core/network/grade_models.dart';
import 'package:numi/features/quiz/helpers/grade_number_from_label.dart';

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
