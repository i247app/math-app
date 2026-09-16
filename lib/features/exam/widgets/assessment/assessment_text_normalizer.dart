String normalizeAssessmentText(String value) {
  return value
      .replaceAll(RegExp(r'[\u180E\u200B\u2060\uFEFF]'), ' ')
      .replaceAll(RegExp(r'[\p{Z}\s]+', unicode: true), ' ')
      .trim();
}
