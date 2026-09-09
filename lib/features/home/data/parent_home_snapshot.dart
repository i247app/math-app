import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/exam/models/exam.dart';

/// Snapshot of home-screen data for a single parent profile.
class ParentHomeSnapshot {
  const ParentHomeSnapshot({
    required this.profileId,
    required this.homeLayout,
    required this.completedAssessments,
    required this.cachedAt,
  });

  final int profileId;

  /// Full layout response from the home-layout API.
  final HomeLayout homeLayout;

  /// Completed exam assessments shown in the home tab.
  final List<GeneratedExam> completedAssessments;

  /// Wall-clock time at which this snapshot was written.
  final DateTime cachedAt;

  static const _staleDuration = Duration(minutes: 5);

  bool get isStale => DateTime.now().difference(cachedAt) > _staleDuration;
}
