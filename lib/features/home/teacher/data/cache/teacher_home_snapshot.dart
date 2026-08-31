import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/classroom/domain/models/classroom.dart';

/// Snapshot of home-screen data for a single teacher profile.
class TeacherHomeSnapshot {
  const TeacherHomeSnapshot({
    required this.profileId,
    required this.layoutClassrooms,
    required this.recentAssignments,
    required this.cachedAt,
  });

  final int profileId;

  /// Classrooms from the teacher's home-layout API response.
  final List<ClassroomModel> layoutClassrooms;

  /// Recently assigned exercises sorted by date.
  final List<ClassroomExercise> recentAssignments;

  /// Wall-clock time at which this snapshot was written.
  final DateTime cachedAt;

  static const _staleDuration = Duration(minutes: 5);

  bool get isStale => DateTime.now().difference(cachedAt) > _staleDuration;
}
