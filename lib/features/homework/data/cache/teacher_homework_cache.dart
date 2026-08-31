import 'dart:async';

import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';

class TeacherHomeworkCache {
  TeacherHomeworkCache._();

  static final Map<_TeacherHomeworkListKey, List<ClassroomExercise>> _lists =
      <_TeacherHomeworkListKey, List<ClassroomExercise>>{};
  static final Map<_TeacherHomeworkListKey, Future<List<ClassroomExercise>>>
  _pendingLists = <_TeacherHomeworkListKey, Future<List<ClassroomExercise>>>{};
  static final Map<_TeacherHomeworkDetailKey, ClassroomExercise?> _details =
      <_TeacherHomeworkDetailKey, ClassroomExercise?>{};
  static final Map<_TeacherHomeworkDetailKey, Future<ClassroomExercise?>>
  _pendingDetails = <_TeacherHomeworkDetailKey, Future<ClassroomExercise?>>{};

  static Future<List<ClassroomExercise>> loadList({
    required ClassroomExerciseService service,
    required int classroomId,
    required int profileId,
    required String purpose,
    bool forceRefresh = false,
  }) {
    final key = _TeacherHomeworkListKey(
      classroomId: classroomId,
      profileId: profileId,
      purpose: purpose,
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
          purpose: purpose,
        )
        .then((exercises) {
          final cachedExercises = List<ClassroomExercise>.unmodifiable(
            exercises,
          );
          _lists[key] = cachedExercises;
          for (final exercise in cachedExercises) {
            final exerciseId = exercise.stableId;
            if (exerciseId != null) {
              _details[_TeacherHomeworkDetailKey(
                    profileId: profileId,
                    exerciseId: exerciseId,
                  )] =
                  exercise;
            }
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
    required String purpose,
  }) {
    return _lists[_TeacherHomeworkListKey(
      classroomId: classroomId,
      profileId: profileId,
      purpose: purpose,
    )];
  }

  static Future<ClassroomExercise?> loadDetail({
    required ClassroomExerciseService service,
    required int exerciseId,
    required int profileId,
    bool forceRefresh = false,
  }) {
    final key = _TeacherHomeworkDetailKey(
      profileId: profileId,
      exerciseId: exerciseId,
    );
    if (!forceRefresh && _details.containsKey(key)) {
      return Future<ClassroomExercise?>.value(_details[key]);
    }
    final pending = _pendingDetails[key];
    if (!forceRefresh && pending != null) {
      return pending;
    }

    late final Future<ClassroomExercise?> request;
    request = service
        .getExerciseDetail(exerciseId: exerciseId, profileId: profileId)
        .then((exercise) {
          _details[key] = exercise;
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

  static ClassroomExercise? peekDetail({
    required int exerciseId,
    required int profileId,
  }) {
    return _details[_TeacherHomeworkDetailKey(
      profileId: profileId,
      exerciseId: exerciseId,
    )];
  }

  static void seedDetail({
    required int profileId,
    required ClassroomExercise exercise,
  }) {
    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      return;
    }
    _details[_TeacherHomeworkDetailKey(
          profileId: profileId,
          exerciseId: exerciseId,
        )] =
        exercise;
  }

  static void replaceDetail({
    required int profileId,
    required ClassroomExercise exercise,
  }) {
    seedDetail(profileId: profileId, exercise: exercise);
    final classroomId = exercise.classroomId;
    if (classroomId != null) {
      invalidateList(
        classroomId: classroomId,
        profileId: profileId,
        purpose: exercise.purpose ?? classroomExercisePurposeHomework,
      );
    }
  }

  static void invalidateList({
    required int classroomId,
    required int profileId,
    required String purpose,
  }) {
    final key = _TeacherHomeworkListKey(
      classroomId: classroomId,
      profileId: profileId,
      purpose: purpose,
    );
    _lists.remove(key);
    _pendingLists.remove(key);
  }
}

class _TeacherHomeworkListKey {
  _TeacherHomeworkListKey({
    required this.classroomId,
    required this.profileId,
    required String purpose,
  }) : purpose = purpose.trim().toUpperCase();

  final int classroomId;
  final int profileId;
  final String purpose;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _TeacherHomeworkListKey &&
            other.classroomId == classroomId &&
            other.profileId == profileId &&
            other.purpose == purpose;
  }

  @override
  int get hashCode => Object.hash(classroomId, profileId, purpose);
}

class _TeacherHomeworkDetailKey {
  const _TeacherHomeworkDetailKey({
    required this.profileId,
    required this.exerciseId,
  });

  final int profileId;
  final int exerciseId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _TeacherHomeworkDetailKey &&
            other.profileId == profileId &&
            other.exerciseId == exerciseId;
  }

  @override
  int get hashCode => Object.hash(profileId, exerciseId);
}
