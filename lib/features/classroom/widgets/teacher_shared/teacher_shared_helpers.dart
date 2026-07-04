part of '../../presentation/teacher_classroom_screens.dart';

InputDecoration _teacherInputDecoration({
  required double scale,
  String? hintText,
  bool outlined = false,
}) {
  final radius = BorderRadius.circular(outlined ? 16 * scale : 12 * scale);
  final borderColor = outlined
      ? const Color(0xFFDDE4E6)
      : const Color(0xFFC4C6D2);
  return InputDecoration(
    hintText: hintText,
    hintStyle: GoogleFonts.andika(
      color: const Color(0x806B7280),
      fontSize: FontSize.normal * scale,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: outlined ? Colors.white : const Color(0xFFF7FAFD),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 17 * scale,
      vertical: 16 * scale,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: outlined ? 2 : 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: teacherTeal, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: outlined ? 2 : 1),
    ),
  );
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String displayTeacherName(StudentProfile? profile) {
  final name = profile?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  return AppStrings.current(AppKeys.teacherFallback);
}

int? _gradeStableId(GradeModel? grade) => grade?.gradeId ?? grade?.id;

int? _programStableId(ProgramModel? program) =>
    program?.programId ?? program?.id;

int? _schoolStableId(SchoolModel? school) => school?.schoolId ?? school?.id;

GradeModel? matchGrade(List<GradeModel> grades, int? id) {
  if (id == null) {
    return null;
  }
  for (final grade in grades) {
    if (_gradeStableId(grade) == id) {
      return grade;
    }
  }
  return null;
}

ProgramModel? matchProgram(List<ProgramModel> programs, int? id) {
  if (id == null) {
    return null;
  }
  for (final program in programs) {
    if (_programStableId(program) == id) {
      return program;
    }
  }
  return null;
}

SchoolModel? matchSchool(List<SchoolModel> schools, int? id) {
  if (id == null) {
    return null;
  }
  for (final school in schools) {
    if (_schoolStableId(school) == id) {
      return school;
    }
  }
  return null;
}

String? displayBackendId(int? value) => value == null ? null : '$value';

String gradeLabel(GradeModel grade) => grade.label?.trim().isNotEmpty == true
    ? grade.label!.trim()
    : AppStrings.current(AppKeys.grade);

String programLabel(ProgramModel program) =>
    program.label?.trim().isNotEmpty == true
    ? program.label!.trim()
    : AppStrings.current(AppKeys.program);

String schoolLabel(SchoolModel school) => school.name?.trim().isNotEmpty == true
    ? school.name!.trim()
    : AppStrings.current(AppKeys.school);
