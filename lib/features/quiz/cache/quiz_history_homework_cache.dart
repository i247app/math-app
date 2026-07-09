import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/classroom/classroom_api.dart';
import 'package:numi/features/homework/homework_api.dart';

class QuizHistoryHomeworkCache {
  QuizHistoryHomeworkCache._();

  static final Map<int, List<ClassroomExercise>> _submittedHomeworkByProfile =
      <int, List<ClassroomExercise>>{};
  static final Map<int, DateTime> _loadedAt = <int, DateTime>{};
  static final Map<int, Future<List<ClassroomExercise>>> _pending =
      <int, Future<List<ClassroomExercise>>>{};

  static Future<List<ClassroomExercise>> loadSubmittedHomework({
    required ClassroomService classroomService,
    required ClassroomExerciseService assignmentService,
    required int profileId,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = _submittedHomeworkByProfile[profileId];
      if (cached != null) {
        return Future<List<ClassroomExercise>>.value(cached);
      }
      final pending = _pending[profileId];
      if (pending != null) {
        return pending;
      }
    }

    late final Future<List<ClassroomExercise>> request;
    request =
        _loadFresh(
              classroomService: classroomService,
              assignmentService: assignmentService,
              profileId: profileId,
            )
            .then((exercises) {
              final cachedExercises = List<ClassroomExercise>.unmodifiable(
                exercises,
              );
              _submittedHomeworkByProfile[profileId] = cachedExercises;
              _loadedAt[profileId] = DateTime.now();
              return cachedExercises;
            })
            .whenComplete(() {
              if (identical(_pending[profileId], request)) {
                _pending.remove(profileId);
              }
            });
    _pending[profileId] = request;
    return request;
  }

  static List<ClassroomExercise>? peekSubmittedHomework(int profileId) {
    return _submittedHomeworkByProfile[profileId];
  }

  static bool isFresh(
    int profileId, {
    Duration maxAge = const Duration(seconds: 45),
  }) {
    final loadedAt = _loadedAt[profileId];
    return loadedAt != null && DateTime.now().difference(loadedAt) <= maxAge;
  }

  static void invalidateProfile(int profileId) {
    _submittedHomeworkByProfile.remove(profileId);
    _loadedAt.remove(profileId);
    _pending.remove(profileId);
  }

  static Future<List<ClassroomExercise>> _loadFresh({
    required ClassroomService classroomService,
    required ClassroomExerciseService assignmentService,
    required int profileId,
  }) async {
    final classrooms = await classroomService.listMyJoinedClassrooms(
      profileId: profileId,
    );
    final classroomIds = classrooms
        .map((classroom) => classroom.stableId)
        .whereType<int>()
        .toSet()
        .toList(growable: false);
    if (classroomIds.isEmpty) {
      return const <ClassroomExercise>[];
    }

    final exerciseGroups = await Future.wait<List<ClassroomExercise>>(
      classroomIds.map((classroomId) {
        return assignmentService.listExercises(
          classroomId: classroomId,
          profileId: profileId,
          visibility: 'PUBLIC',
          submissionStatus: 'SUBMITTED',
          purpose: classroomExercisePurposeHomework,
        );
      }),
    );

    final seenIds = <int>{};
    final exercises = <ClassroomExercise>[];
    for (final group in exerciseGroups) {
      for (final exercise in group) {
        final exerciseId = exercise.stableId;
        if (exerciseId != null && !seenIds.add(exerciseId)) {
          continue;
        }
        exercises.add(exercise);
      }
    }
    return exercises;
  }
}
