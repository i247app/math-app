import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/exam/helpers/grade_number_from_label.dart';

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
      return 'assets/images/grade-selection-k.png';
    }

    return switch (number) {
      '1' => 'assets/images/grade-selection-1.png',
      '2' => 'assets/images/grade-selection-2.png',
      '3' => 'assets/images/grade-selection-3.png',
      '4' => 'assets/images/grade-selection-4.png',
      '5' => 'assets/images/grade-selection-5.png',
      _ => null,
    };
  }
}
