import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/quiz_models.dart';

/// Snapshot of home-screen data for a single student profile.
///
/// Used by [HomeProfileCache] to implement stale-while-revalidate: when the
/// user switches back to a previously-visited profile the cached data is shown
/// immediately while a background refresh runs if the snapshot is [isStale].
class StudentHomeSnapshot {
  const StudentHomeSnapshot({
    required this.profileId,
    required this.layoutClassrooms,
    required this.modeHomeworkExercises,
    required this.completedAssessments,
    required this.cachedAt,
  });

  final int profileId;

  /// Classrooms from the home-layout API response.
  final List<ClassroomModel> layoutClassrooms;

  /// Pending homework exercises for the current homework-mode classroom.
  final List<ClassroomExercise> modeHomeworkExercises;

  /// Completed quiz assessments shown in the home tab.
  final List<GeneratedQuiz> completedAssessments;

  /// Wall-clock time at which this snapshot was written.
  final DateTime cachedAt;

  /// Snapshot is considered stale after 5 minutes.
  static const _staleDuration = Duration(minutes: 5);

  bool get isStale => DateTime.now().difference(cachedAt) > _staleDuration;
}
