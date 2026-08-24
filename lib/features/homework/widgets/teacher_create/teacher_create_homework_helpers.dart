import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/profile/data/dto/grade_models.dart';
import 'package:numi/features/profile/data/dto/program_models.dart';
import 'package:numi/features/profile/data/dto/school_models.dart';
import 'package:numi/shared/helpers/teacher_profile_option_helpers.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_helpers.dart';

String trimOrDefault(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

String? formatCreateHomeworkDate(DateTime? value) {
  if (value == null) {
    return null;
  }
  return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

String exerciseApiDate(DateTime value) {
  final utc = value.toUtc();
  final micros = utc.millisecond * 1000 + utc.microsecond;
  return '${utc.year.toString().padLeft(4, '0')}-'
      '${twoDigits(utc.month)}-'
      '${twoDigits(utc.day)}T'
      '${twoDigits(utc.hour)}:'
      '${twoDigits(utc.minute)}:'
      '${twoDigits(utc.second)}.'
      '${micros.toString().padLeft(6, '0')}Z';
}

String createHomeworkClassName(
  BuildContext context,
  ClassroomModel? classroom,
) {
  final name = classroom?.name?.trim();
  return name == null || name.isEmpty
      ? context.getText(AppKeys.teacherAssignmentClassOption)
      : name;
}

String createHomeworkClassSummaryName(
  BuildContext context,
  ClassroomModel? classroom,
) {
  final name = classroom?.name?.trim();
  return name == null || name.isEmpty
      ? context.getText(AppKeys.teacherAssignmentClassSummaryName)
      : name;
}

String createHomeworkStudentCount(
  BuildContext context,
  ClassroomModel? classroom,
) {
  final count = classroom?.displayStudentCount;
  if (count == null || count <= 0) {
    return context.getText(AppKeys.teacherAssignmentClassStudentCount);
  }
  return context.formatText(AppKeys.teacherAssignmentClassStudentCountFormat, {
    'count': count,
  });
}

String createHomeworkGradeName(
  BuildContext context,
  ClassroomModel? classroom,
  List<GradeModel> grades,
) {
  final grade = matchGrade(grades, classroom?.gradeId);
  if (grade != null) {
    return gradeLabel(grade);
  }
  final gradeId = classroom?.gradeId;
  if (gradeId != null) {
    return '${context.getText(AppKeys.grade)} ${displayBackendId(gradeId)}';
  }
  return context.getText(AppKeys.teacherAssignmentClassGrade);
}

String createHomeworkProgramName(
  BuildContext context,
  ClassroomModel? classroom,
  List<ProgramModel> programs, {
  int? selectedProgramId,
}) {
  final options = programOptionsForClassroom(context, classroom, programs);
  if (selectedProgramId == null && options.isNotEmpty) {
    return options.map((option) => option.label).join(', ');
  }

  final selectedId = selectedProgramId ?? _defaultProgramId(classroom);
  for (final option in options) {
    if (option.id == selectedId) {
      return option.label;
    }
  }

  return context.getText(AppKeys.teacherProgramFallback);
}

String? selectedHomeworkProgramName(
  BuildContext context,
  List<ProgramModel> programs,
  int? selectedProgramId,
) {
  if (selectedProgramId == null) {
    return null;
  }
  final program = matchProgram(programs, selectedProgramId);
  if (program != null) {
    return programLabel(program);
  }
  return '${context.getText(AppKeys.teacherProgramFallback)} '
      '$selectedProgramId';
}

String createHomeworkSchoolName(
  BuildContext context,
  ClassroomModel? classroom,
  List<SchoolModel> schools,
) {
  final school = matchSchool(schools, classroom?.schoolId);
  if (school != null) {
    return schoolLabel(school);
  }
  return displayBackendId(classroom?.schoolId) ??
      context.getText(AppKeys.school);
}

int? _defaultProgramId(ClassroomModel? classroom) {
  if (classroom?.programId != null) {
    return classroom!.programId;
  }
  final programIds = classroom?.programIds ?? const <int>[];
  return programIds.isEmpty ? null : programIds.first;
}

int? validProgramIdForClassroom(
  ClassroomModel? classroom,
  int? selectedProgramId,
  List<ProgramModel> programs,
) {
  final options = _programOptionsForClassroomWithoutContext(
    classroom,
    programs,
  );
  if (selectedProgramId == null) {
    return null;
  }
  if (options.isEmpty ||
      options.any((option) => option.id == selectedProgramId)) {
    return selectedProgramId;
  }
  return null;
}

List<ClassroomProgramOption> programOptionsForClassroom(
  BuildContext context,
  ClassroomModel? classroom,
  List<ProgramModel> programs,
) {
  final options = _programOptionsForClassroomWithoutContext(
    classroom,
    programs,
  );
  if (options.isEmpty) {
    return const <ClassroomProgramOption>[];
  }
  return options
      .map((option) {
        if (option.label.isNotEmpty) {
          return option;
        }
        return ClassroomProgramOption(
          id: option.id,
          label:
              '${context.getText(AppKeys.teacherProgramFallback)} ${option.id}',
        );
      })
      .toList(growable: false);
}

List<ClassroomProgramOption> _programOptionsForClassroomWithoutContext(
  ClassroomModel? classroom,
  List<ProgramModel> programs,
) {
  if (classroom == null) {
    return const <ClassroomProgramOption>[];
  }

  final ids = <int>[
    if (classroom.programId != null) classroom.programId!,
    for (final id in classroom.programIds)
      if (id != classroom.programId) id,
  ];
  if (ids.isEmpty) {
    return const <ClassroomProgramOption>[];
  }

  return ids
      .map((id) {
        final program = matchProgram(programs, id);
        return ClassroomProgramOption(
          id: id,
          label: program == null ? '' : programLabel(program),
        );
      })
      .toList(growable: false);
}

class ClassroomProgramOption {
  const ClassroomProgramOption({required this.id, required this.label});

  final int id;
  final String label;
}

List<ClassroomModel> mergeSelectedClassroom(
  List<ClassroomModel> classrooms,
  ClassroomModel? selectedClassroom,
) {
  final selectedId = selectedClassroom?.stableId;
  if (selectedClassroom == null ||
      selectedId == null ||
      matchingClassroom(classrooms, selectedId) != null) {
    return classrooms;
  }
  return <ClassroomModel>[selectedClassroom, ...classrooms];
}

ClassroomModel? matchingClassroom(
  List<ClassroomModel> classrooms,
  int classroomId,
) {
  for (final classroom in classrooms) {
    if (classroom.stableId == classroomId) {
      return classroom;
    }
  }
  return null;
}
