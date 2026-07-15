import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/program_models.dart';
import 'package:numi/core/network/school_models.dart';

int? gradeStableId(GradeModel? grade) => grade?.gradeId ?? grade?.id;

int? programStableId(ProgramModel? program) =>
    program?.programId ?? program?.id;

int? schoolStableId(SchoolModel? school) => school?.schoolId ?? school?.id;

GradeModel? matchGrade(List<GradeModel> grades, int? id) {
  if (id == null) {
    return null;
  }
  for (final grade in grades) {
    if (gradeStableId(grade) == id) {
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
    if (programStableId(program) == id) {
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
    if (schoolStableId(school) == id) {
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
