part of '../../presentation/teacher_classroom_screens.dart';

String _detailIdLabel(String prefix, int? value) {
  final displayValue = _displayBackendId(value);
  if (displayValue == null) {
    return prefix;
  }
  return '$prefix $displayValue';
}

String? _displayBackendId(int? value) => value == null ? null : '$value';

String _classroomGradeLabel(
  BuildContext context,
  ClassroomModel? classroom,
  List<GradeModel> grades,
) {
  final grade = _matchGrade(grades, classroom?.gradeId);
  if (grade != null) {
    return _gradeLabel(grade);
  }
  return _detailIdLabel(context.getText(AppKeys.grade), classroom?.gradeId);
}

String? _classroomProgramLabel(
  BuildContext context,
  ClassroomModel? classroom,
  List<ProgramModel> programs,
) {
  final ids = _classroomProgramIds(classroom);
  final labels = <String>[];
  for (final id in ids) {
    final program = _matchProgram(programs, id);
    labels.add(
      program == null
          ? '${context.getText(AppKeys.teacherProgramFallback)} $id'
          : _programLabel(program),
    );
  }
  if (labels.isNotEmpty) {
    return labels.join(', ');
  }
  return null;
}

List<int> _classroomProgramIds(ClassroomModel? classroom) {
  if (classroom == null) {
    return const <int>[];
  }

  final ids = <int>[];
  void addId(int? id) {
    if (id != null && !ids.contains(id)) {
      ids.add(id);
    }
  }

  addId(classroom.programId);
  for (final id in classroom.programIds) {
    addId(id);
  }
  return ids;
}

String _classroomSchoolLabel(
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

String _classCode(ClassroomModel? classroom) {
  final classroomCode = _nonEmpty(classroom?.classroomCode);
  if (classroomCode != null) {
    return classroomCode;
  }
  final stableId = classroom?.stableId;
  if (stableId == null) {
    return 'NM-9988';
  }
  final cleaned = _displayClassStableId(stableId);
  if (cleaned.isEmpty) {
    return 'NM-9988';
  }
  final suffix = cleaned.length > 4
      ? cleaned.substring(cleaned.length - 4)
      : cleaned.padLeft(4, '0');
  return 'NM-$suffix';
}

String _displayClassStableId(int value) => '$value';

void _copyClassroomInfo(BuildContext context, String value) {
  Clipboard.setData(ClipboardData(text: value));
  HapticFeedback.selectionClick();
}
