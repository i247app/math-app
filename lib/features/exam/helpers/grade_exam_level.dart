/// GRADE uses 0-9 on the API and roadmap, and 1-10 in progress models.
abstract final class GradeExamLevel {
  static int toApi(int progressLevel) => progressLevel.clamp(1, 10) - 1;

  static int fromApi(int apiLevel) => apiLevel + 1;

  static int? forExamType(int? apiLevel, String? examType) =>
      apiLevel != null && examType?.trim().toUpperCase() == 'GRADE'
      ? fromApi(apiLevel)
      : apiLevel;
}
