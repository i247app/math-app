part of '../../presentation/grade_selection_screen.dart';

String? _gradeNumberFromLabel(String label) {
  final match = RegExp(r'\d+').firstMatch(label);
  return match?.group(0);
}
