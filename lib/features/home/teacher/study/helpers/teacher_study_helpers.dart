part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

List<ClassroomExercise> _deduplicateTeacherStudyExercises(
  List<ClassroomExercise> exercises,
) {
  final ids = <int>{};
  return exercises.where((exercise) {
    final id = exercise.stableId;
    return id == null || ids.add(id);
  }).toList(growable: false);
}

int _compareTeacherStudyExercises(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = _teacherStudySortDate(first);
  final secondDate = _teacherStudySortDate(second);
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

DateTime? _teacherStudySortDate(ClassroomExercise exercise) {
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

_TeacherStudyDateParts? _teacherStudyDateParts(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return _TeacherStudyDateParts(
    day: _twoDigits(local.day),
    month: _twoDigits(local.month),
  );
}

String? _teacherStudyDateLabel(BuildContext context, String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  final day = _twoDigits(local.day);
  final month = _twoDigits(local.month);
  if (Localizations.localeOf(context).languageCode.toLowerCase() == 'en') {
    return '$month/$day/${local.year}';
  }
  return '$day/$month/${local.year}';
}
