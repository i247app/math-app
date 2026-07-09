import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';

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

String teacherExercisePurpose(ClassroomExercise exercise) {
  final purpose = exercise.purpose?.trim().toUpperCase();
  if (purpose == classroomExercisePurposeExam ||
      purpose == classroomExercisePurposeQuiz) {
    return classroomExercisePurposeExam;
  }
  return classroomExercisePurposeHomework;
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
