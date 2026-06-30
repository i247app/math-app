part of '../../../classroom/presentation/teacher_classroom_screens.dart';

String _trimOrDefault(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

String? _formatCreateHomeworkDate(DateTime? value) {
  if (value == null) {
    return null;
  }
  return '${_twoDigits(value.day)}/${_twoDigits(value.month)}/${value.year} '
      '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
}

String _exerciseApiDate(DateTime value) {
  final utc = value.toUtc();
  final micros = utc.millisecond * 1000 + utc.microsecond;
  return '${utc.year.toString().padLeft(4, '0')}-'
      '${_twoDigits(utc.month)}-'
      '${_twoDigits(utc.day)}T'
      '${_twoDigits(utc.hour)}:'
      '${_twoDigits(utc.minute)}:'
      '${_twoDigits(utc.second)}.'
      '${micros.toString().padLeft(6, '0')}Z';
}

String _createHomeworkClassName(
  BuildContext context,
  ClassroomModel? classroom,
) {
  final name = classroom?.name?.trim();
  return name == null || name.isEmpty
      ? context.getText(AppKeys.teacherAssignmentClassOption)
      : name;
}

String _createHomeworkClassSummaryName(
  BuildContext context,
  ClassroomModel? classroom,
) {
  final name = classroom?.name?.trim();
  return name == null || name.isEmpty
      ? context.getText(AppKeys.teacherAssignmentClassSummaryName)
      : name;
}

String _createHomeworkStudentCount(
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

String _createHomeworkGradeName(
  BuildContext context,
  ClassroomModel? classroom,
  List<GradeModel> grades,
) {
  final grade = _matchGrade(grades, classroom?.gradeId);
  if (grade != null) {
    return _gradeLabel(grade);
  }
  final gradeId = classroom?.gradeId;
  if (gradeId != null) {
    return '${context.getText(AppKeys.grade)} ${_displayBackendId(gradeId)}';
  }
  return context.getText(AppKeys.teacherAssignmentClassGrade);
}

String _createHomeworkProgramName(
  BuildContext context,
  ClassroomModel? classroom,
  List<ProgramModel> programs, {
  int? selectedProgramId,
}) {
  final options = _programOptionsForClassroom(context, classroom, programs);
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

String? _selectedHomeworkProgramName(
  BuildContext context,
  List<ProgramModel> programs,
  int? selectedProgramId,
) {
  if (selectedProgramId == null) {
    return null;
  }
  final program = _matchProgram(programs, selectedProgramId);
  if (program != null) {
    return _programLabel(program);
  }
  return '${context.getText(AppKeys.teacherProgramFallback)} '
      '$selectedProgramId';
}

String _createHomeworkSchoolName(
  BuildContext context,
  ClassroomModel? classroom,
  List<SchoolModel> schools,
) {
  final school = _matchSchool(schools, classroom?.schoolId);
  if (school != null) {
    return _schoolLabel(school);
  }
  return _displayBackendId(classroom?.schoolId) ??
      context.getText(AppKeys.school);
}

int? _defaultProgramId(ClassroomModel? classroom) {
  if (classroom?.programId != null) {
    return classroom!.programId;
  }
  final programIds = classroom?.programIds ?? const <int>[];
  return programIds.isEmpty ? null : programIds.first;
}

int? _validProgramIdForClassroom(
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

List<_ClassroomProgramOption> _programOptionsForClassroom(
  BuildContext context,
  ClassroomModel? classroom,
  List<ProgramModel> programs,
) {
  final options = _programOptionsForClassroomWithoutContext(
    classroom,
    programs,
  );
  if (options.isEmpty) {
    return const <_ClassroomProgramOption>[];
  }
  return options
      .map((option) {
        if (option.label.isNotEmpty) {
          return option;
        }
        return _ClassroomProgramOption(
          id: option.id,
          label:
              '${context.getText(AppKeys.teacherProgramFallback)} ${option.id}',
        );
      })
      .toList(growable: false);
}

List<_ClassroomProgramOption> _programOptionsForClassroomWithoutContext(
  ClassroomModel? classroom,
  List<ProgramModel> programs,
) {
  if (classroom == null) {
    return const <_ClassroomProgramOption>[];
  }

  final ids = <int>[
    if (classroom.programId != null) classroom.programId!,
    for (final id in classroom.programIds)
      if (id != classroom.programId) id,
  ];
  if (ids.isEmpty) {
    return const <_ClassroomProgramOption>[];
  }

  return ids
      .map((id) {
        final program = _matchProgram(programs, id);
        return _ClassroomProgramOption(
          id: id,
          label: program == null ? '' : _programLabel(program),
        );
      })
      .toList(growable: false);
}

class _ClassroomProgramOption {
  const _ClassroomProgramOption({required this.id, required this.label});

  final int id;
  final String label;
}

List<ClassroomModel> _mergeSelectedClassroom(
  List<ClassroomModel> classrooms,
  ClassroomModel? selectedClassroom,
) {
  final selectedId = selectedClassroom?.stableId;
  if (selectedClassroom == null ||
      selectedId == null ||
      _matchingClassroom(classrooms, selectedId) != null) {
    return classrooms;
  }
  return <ClassroomModel>[selectedClassroom, ...classrooms];
}

ClassroomModel? _matchingClassroom(
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
