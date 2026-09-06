import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';

class QuizHistoryClassroomExerciseCache {
  QuizHistoryClassroomExerciseCache._();

  static final Map<int, List<ClassroomExercise>>
  _submittedClassroomExerciseByProfile = <int, List<ClassroomExercise>>{};
  static final Map<int, DateTime> _loadedAt = <int, DateTime>{};
  static final Map<int, Future<List<ClassroomExercise>>> _pending =
      <int, Future<List<ClassroomExercise>>>{};

  static Future<List<ClassroomExercise>> loadSubmittedClassroomExercise({
    required ClassroomService classroomService,
    required ClassroomExerciseService assignmentService,
    required int profileId,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = _submittedClassroomExerciseByProfile[profileId];
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
              _submittedClassroomExerciseByProfile[profileId] = cachedExercises;
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

  static List<ClassroomExercise>? peekSubmittedClassroomExercise(
    int profileId,
  ) {
    return _submittedClassroomExerciseByProfile[profileId];
  }

  static bool isFresh(
    int profileId, {
    Duration maxAge = const Duration(seconds: 45),
  }) {
    final loadedAt = _loadedAt[profileId];
    return loadedAt != null && DateTime.now().difference(loadedAt) <= maxAge;
  }

  static void invalidateProfile(int profileId) {
    _submittedClassroomExerciseByProfile.remove(profileId);
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
