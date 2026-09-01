import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';

bool isTeacherProfileComplete(StudentProfile? profile) {
  return profile?.profileStatus?.trim().toUpperCase() == 'OFFICIAL';
}

int compareRecentAssignments(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = _recentAssignmentSortDate(first);
  final secondDate = _recentAssignmentSortDate(second);
  final firstMs = firstDate?.millisecondsSinceEpoch ?? -1;
  final secondMs = secondDate?.millisecondsSinceEpoch ?? -1;
  final dateCompare = secondMs.compareTo(firstMs);
  if (dateCompare != 0) {
    return dateCompare;
  }
  return (second.stableId ?? -1).compareTo(first.stableId ?? -1);
}

DateTime? _recentAssignmentSortDate(ClassroomExercise exercise) {
  final values = <String?>[
    exercise.createDt,
    exercise.modifyDt,
    exercise.startDate,
    exercise.endDate,
  ];
  for (final value in values) {
    final parsed = DateTime.tryParse(value?.trim() ?? '');
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}
