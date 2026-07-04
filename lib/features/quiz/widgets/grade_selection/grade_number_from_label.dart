String? gradeNumberFromLabel(String label) {
  final match = RegExp(r'\d+').firstMatch(label);
  return match?.group(0);
}
