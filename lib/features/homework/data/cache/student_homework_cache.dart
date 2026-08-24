import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/data/homework_api.dart';

class StudentHomeworkCache {
  StudentHomeworkCache._();

  static const _emptyDetailRetryDelay = Duration(milliseconds: 450);

  static final Map<_StudentHomeworkListKey, List<ClassroomExercise>> _lists =
      <_StudentHomeworkListKey, List<ClassroomExercise>>{};
  static final Map<_StudentHomeworkListKey, Future<List<ClassroomExercise>>>
  _pendingLists = <_StudentHomeworkListKey, Future<List<ClassroomExercise>>>{};
  static final Map<_StudentHomeworkDetailKey, _StudentHomeworkDetailEntry>
  _details = <_StudentHomeworkDetailKey, _StudentHomeworkDetailEntry>{};
  static final Map<_StudentHomeworkDetailKey, Future<ClassroomExercise?>>
  _pendingDetails = <_StudentHomeworkDetailKey, Future<ClassroomExercise?>>{};

  static Future<List<ClassroomExercise>> loadList({
    required ClassroomExerciseService service,
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
    bool forceRefresh = false,
  }) {
    final key = _StudentHomeworkListKey(
      classroomId: classroomId,
      profileId: profileId,
      search: search,
      visibility: visibility,
      submissionStatus: submissionStatus,
    );
    final cached = _lists[key];
    if (!forceRefresh && cached != null) {
      return Future<List<ClassroomExercise>>.value(cached);
    }
    final pending = _pendingLists[key];
    if (!forceRefresh && pending != null) {
      return pending;
    }

    late final Future<List<ClassroomExercise>> request;
    request = service
        .listExercises(
          classroomId: classroomId,
          profileId: profileId,
          search: key.search,
          visibility: key.visibility,
          submissionStatus: key.submissionStatus,
        )
        .then((exercises) {
          final cachedExercises = List<ClassroomExercise>.unmodifiable(
            exercises,
          );
          _lists[key] = cachedExercises;
          for (final exercise in cachedExercises) {
            seedDetail(profileId: profileId, exercise: exercise);
          }
          return cachedExercises;
        })
        .whenComplete(() {
          if (identical(_pendingLists[key], request)) {
            _pendingLists.remove(key);
          }
        });
    _pendingLists[key] = request;
    return request;
  }

  static List<ClassroomExercise>? peekList({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
  }) {
    return _lists[_StudentHomeworkListKey(
      classroomId: classroomId,
      profileId: profileId,
      search: search,
      visibility: visibility,
      submissionStatus: submissionStatus,
    )];
  }

  static Future<ClassroomExercise?> loadDetail({
    required ClassroomExerciseService service,
    required int exerciseId,
    required int profileId,
    bool forceRefresh = false,
  }) {
    final key = _StudentHomeworkDetailKey(
      profileId: profileId,
      exerciseId: exerciseId,
    );
    final cached = _details[key];
    if (!forceRefresh && cached != null && cached.hasFullDetail) {
      return Future<ClassroomExercise?>.value(cached.exercise);
    }
    final pending = _pendingDetails[key];
    if (!forceRefresh && pending != null) {
      return pending;
    }

    late final Future<ClassroomExercise?> request;
    request =
        _loadDetailWithEmptyResponseRetry(
              service: service,
              exerciseId: exerciseId,
              profileId: profileId,
            )
            .then((exercise) {
              if (exercise != null) {
                seedDetail(
                  profileId: profileId,
                  exercise: exercise,
                  hasFullDetail: true,
                );
              }
              return exercise;
            })
            .whenComplete(() {
              if (identical(_pendingDetails[key], request)) {
                _pendingDetails.remove(key);
              }
            });
    _pendingDetails[key] = request;
    return request;
  }

  /// A newly created homework can be visible before question generation has
  /// completed. Give the backend one brief extra attempt while the UI keeps
  /// its loading skeleton visible.
  static Future<ClassroomExercise?> _loadDetailWithEmptyResponseRetry({
    required ClassroomExerciseService service,
    required int exerciseId,
    required int profileId,
  }) async {
    final exercise = await service.getExerciseDetail(
      exerciseId: exerciseId,
      profileId: profileId,
    );
    if (exercise?.questions.isNotEmpty == true) {
      return exercise;
    }

    await Future<void>.delayed(_emptyDetailRetryDelay);
    return service.getExerciseDetail(
      exerciseId: exerciseId,
      profileId: profileId,
    );
  }

  static ClassroomExercise? peekFullDetail({
    required int exerciseId,
    required int profileId,
  }) {
    final cached =
        _details[_StudentHomeworkDetailKey(
          profileId: profileId,
          exerciseId: exerciseId,
        )];
    return cached?.hasFullDetail == true ? cached!.exercise : null;
  }

  static void seedDetail({
    required int profileId,
    required ClassroomExercise exercise,
    bool? hasFullDetail,
  }) {
    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      return;
    }
    final key = _StudentHomeworkDetailKey(
      profileId: profileId,
      exerciseId: exerciseId,
    );
    final existing = _details[key];
    final incomingHasFullDetail =
        hasFullDetail ?? exercise.questions.isNotEmpty;
    if (existing != null && existing.hasFullDetail && !incomingHasFullDetail) {
      return;
    }
    _details[key] = _StudentHomeworkDetailEntry(
      exercise: exercise,
      hasFullDetail: incomingHasFullDetail,
    );
  }

  static void markSubmitted({
    required int profileId,
    required ClassroomExercise exercise,
  }) {
    final submittedExercise = _withSubmissionStatus(exercise, 'SUBMITTED');
    seedDetail(
      profileId: profileId,
      exercise: submittedExercise,
      hasFullDetail: exercise.questions.isNotEmpty,
    );

    final classroomId = submittedExercise.classroomId;
    if (classroomId == null) {
      invalidateListsForProfile(profileId);
      return;
    }

    final updatedLists = <_StudentHomeworkListKey, List<ClassroomExercise>>{};
    final removedKeys = <_StudentHomeworkListKey>[];
    for (final entry in _lists.entries) {
      final key = entry.key;
      if (key.profileId != profileId || key.classroomId != classroomId) {
        continue;
      }
      final hasExercise = entry.value.any(
        (item) => item.stableId == submittedExercise.stableId,
      );
      if (!hasExercise) {
        if (key.submissionStatus == 'SUBMITTED') {
          removedKeys.add(key);
        }
        continue;
      }

      if (key.submissionStatus == 'SUBMITTED') {
        updatedLists[key] = List<ClassroomExercise>.unmodifiable(
          entry.value.map((item) {
            return item.stableId == submittedExercise.stableId
                ? submittedExercise
                : item;
          }),
        );
      } else {
        updatedLists[key] = List<ClassroomExercise>.unmodifiable(
          entry.value.where(
            (item) => item.stableId != submittedExercise.stableId,
          ),
        );
      }
    }

    for (final key in removedKeys) {
      _lists.remove(key);
    }
    _lists.addAll(updatedLists);
    _pendingLists.removeWhere(
      (key, _) => key.profileId == profileId && key.classroomId == classroomId,
    );
  }

  static void invalidateListsForProfile(int profileId) {
    _lists.removeWhere((key, _) => key.profileId == profileId);
    _pendingLists.removeWhere((key, _) => key.profileId == profileId);
  }

  static ClassroomExercise _withSubmissionStatus(
    ClassroomExercise exercise,
    String submissionStatus,
  ) {
    return ClassroomExercise.fromJson(<String, dynamic>{
      ...exercise.toJson(),
      'submission_status': submissionStatus,
    });
  }
}

class _StudentHomeworkDetailEntry {
  const _StudentHomeworkDetailEntry({
    required this.exercise,
    required this.hasFullDetail,
  });

  final ClassroomExercise exercise;
  final bool hasFullDetail;
}

class _StudentHomeworkListKey {
  _StudentHomeworkListKey({
    required this.classroomId,
    required this.profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
  }) : search = _normalizeNullable(search),
       visibility = _normalizeNullable(visibility)?.toUpperCase(),
       submissionStatus = _normalizeNullable(submissionStatus)?.toUpperCase();

  final int classroomId;
  final int profileId;
  final String? search;
  final String? visibility;
  final String? submissionStatus;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _StudentHomeworkListKey &&
            other.classroomId == classroomId &&
            other.profileId == profileId &&
            other.search == search &&
            other.visibility == visibility &&
            other.submissionStatus == submissionStatus;
  }

  @override
  int get hashCode =>
      Object.hash(classroomId, profileId, search, visibility, submissionStatus);
}

class _StudentHomeworkDetailKey {
  const _StudentHomeworkDetailKey({
    required this.profileId,
    required this.exerciseId,
  });

  final int profileId;
  final int exerciseId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _StudentHomeworkDetailKey &&
            other.profileId == profileId &&
            other.exerciseId == exerciseId;
  }

  @override
  int get hashCode => Object.hash(profileId, exerciseId);
}

String? _normalizeNullable(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
