import 'package:flutter/material.dart';

import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/models/teacher_study_date_parts.dart';

List<ClassroomExercise> deduplicateTeacherStudyExercises(
  List<ClassroomExercise> exercises,
) {
  final ids = <int>{};
  return exercises
      .where((exercise) {
        final id = exercise.stableId;
        return id == null || ids.add(id);
      })
      .toList(growable: false);
}

int compareTeacherStudyExercises(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = teacherStudySortDate(first);
  final secondDate = teacherStudySortDate(second);
  if (firstDate == null && secondDate == null) {
    return (second.stableId ?? 0).compareTo(first.stableId ?? 0);
  }
  if (firstDate == null) {
    return 1;
  }
  if (secondDate == null) {
    return -1;
  }
  return secondDate.compareTo(firstDate);
}

DateTime? teacherStudySortDate(ClassroomExercise exercise) {
  for (final value in [
    exercise.createDt,
    exercise.startDate,
    exercise.endDate,
  ]) {
    final parsed = DateTime.tryParse(value?.trim() ?? '');
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

TeacherStudyDateParts? teacherStudyDateParts(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return TeacherStudyDateParts(
    day: teacherStudyTwoDigits(local.day),
    month: teacherStudyTwoDigits(local.month),
  );
}

String? teacherStudyDateLabel(BuildContext context, String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  final day = teacherStudyTwoDigits(local.day);
  final month = teacherStudyTwoDigits(local.month);
  if (Localizations.localeOf(context).languageCode.toLowerCase() == 'en') {
    return '$month/$day/${local.year}';
  }
  return '$day/$month/${local.year}';
}

String teacherStudyTwoDigits(int value) => value.toString().padLeft(2, '0');
