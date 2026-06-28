import 'package:flutter/widgets.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/core/network/school_models.dart';

List<SchoolModel> selectedStudentJoinSchools(
  List<SchoolModel> schools,
  Set<int> selectedSchoolIds,
) {
  if (selectedSchoolIds.isEmpty) {
    return const <SchoolModel>[];
  }
  return schools
      .where((school) => selectedSchoolIds.contains(schoolStableId(school)))
      .toList(growable: false);
}

int? gradeStableId(GradeModel grade) => grade.gradeId ?? grade.id;

int? schoolStableId(SchoolModel school) => school.schoolId ?? school.id;

String studentJoinGradeLabel(BuildContext context, GradeModel grade) {
  final label = grade.label?.trim();
  if (label != null && label.isNotEmpty) {
    return label;
  }
  final description = grade.description?.trim();
  if (description != null && description.isNotEmpty) {
    return description;
  }
  final id = gradeStableId(grade);
  return id == null
      ? context.getText(AppKeys.grade)
      : context.formatText(AppKeys.studentGradeFilter, {'grade': id});
}

String studentJoinSchoolName(BuildContext context, SchoolModel school) {
  final name = school.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  final id = schoolStableId(school);
  return id == null ? context.getText(AppKeys.school) : 'ID: $id';
}

bool intSetEquals(Set<int> first, Set<int> second) {
  if (first.length != second.length) {
    return false;
  }
  for (final value in first) {
    if (!second.contains(value)) {
      return false;
    }
  }
  return true;
}

String? classroomCode(ClassroomModel classroom) {
  final code = classroom.classroomCode?.trim();
  if (code != null && code.isNotEmpty) {
    return code;
  }
  return null;
}
