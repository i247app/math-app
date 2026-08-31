import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/domain/models/classroom.dart';
import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/profile/domain/models/program.dart';
import 'package:numi/features/profile/domain/models/school.dart';
import 'package:numi/shared/helpers/teacher_profile_option_helpers.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_shared_helpers.dart';

String _detailIdLabel(String prefix, int? value) {
  final displayValue = displayBackendId(value);
  if (displayValue == null) {
    return prefix;
  }
  return '$prefix $displayValue';
}

String classroomGradeLabel(
  BuildContext context,
  ClassroomModel? classroom,
  List<GradeModel> grades,
) {
  final grade = matchGrade(grades, classroom?.gradeId);
  if (grade != null) {
    return gradeLabel(grade);
  }
  return _detailIdLabel(context.getText(AppKeys.grade), classroom?.gradeId);
}

String? classroomProgramLabel(
  BuildContext context,
  ClassroomModel? classroom,
  List<ProgramModel> programs,
) {
  final ids = _classroomProgramIds(classroom);
  final labels = <String>[];
  for (final id in ids) {
    final program = matchProgram(programs, id);
    labels.add(
      program == null
          ? '${context.getText(AppKeys.teacherProgramFallback)} $id'
          : programLabel(program),
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

String classroomSchoolLabel(
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

String classCode(ClassroomModel? classroom) {
  final classroomCode = nonEmpty(classroom?.classroomCode);
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

void copyClassroomInfo(BuildContext context, String value) {
  Clipboard.setData(ClipboardData(text: value));
  HapticFeedback.selectionClick();
}
