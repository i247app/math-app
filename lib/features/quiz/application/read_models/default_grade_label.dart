import 'package:numi/features/profile/domain/models/grade.dart';

String? defaultGradeLabel(
  List<GradeModel> grades, {
  int? preferredGradeId,
  String? preferredGradeLabel,
  bool fallbackToFirst = true,
}) {
  final sortedGrades =
      grades.where((grade) => grade.label?.trim().isNotEmpty == true).toList()
        ..sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
  if (sortedGrades.isEmpty) {
    return null;
  }

  if (preferredGradeId != null) {
    for (final grade in sortedGrades) {
      if ((grade.gradeId ?? grade.id) == preferredGradeId) {
        return grade.label?.trim();
      }
    }
  }

  final cleanPreferredLabel = preferredGradeLabel?.trim();
  if (cleanPreferredLabel?.isNotEmpty == true) {
    for (final grade in sortedGrades) {
      final label = grade.label?.trim();
      if (label?.toLowerCase() == cleanPreferredLabel!.toLowerCase()) {
        return label;
      }
    }
  }

  return fallbackToFirst ? sortedGrades.first.label?.trim() : null;
}
