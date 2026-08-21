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

  bool get isKindergarten {
    final normalized = label.trim().toLowerCase();
    return normalized.contains('mẫu giáo') ||
        normalized.contains('mau giao') ||
        normalized.contains('kindergarten');
  }

  String? get iconAsset {
    if (isKindergarten) {
      return 'assets/icons/mau_giao.svg';
    }

    return switch (number) {
      '1' => 'assets/icons/1.svg',
      '2' => 'assets/icons/2.svg',
      '3' => 'assets/icons/3.svg',
      '4' => 'assets/icons/4.svg',
      '5' => 'assets/icons/5.svg',
      _ => null,
    };
  }
}
