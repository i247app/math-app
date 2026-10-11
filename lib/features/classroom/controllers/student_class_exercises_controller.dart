import 'package:flutter/foundation.dart';
import 'package:numi/core/data/app_failure.dart';
import 'package:numi/core/data/async_resource.dart';
import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/features/classroom/controllers/classroom_state.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

class StudentClassExercisesController extends ChangeNotifier {
  StudentClassExercisesController({
    required ClassroomExerciseService exerciseService,
  }) : _exerciseService = exerciseService;
  final ClassroomExerciseService _exerciseService;
  AsyncResource<List<ClassroomExercise>> _state = const AsyncResource.idle();
  AsyncResource<List<ClassroomExercise>> get state => _state;
  ClassroomDataKey? _key;
  int _revision = 0;
  bool _disposed = false;

  Future<void> load({required int profileId, required int classroomId}) async {
    if (_disposed) return;
    final revision = ++_revision;
    final scope = SessionCacheScope.current;
    final key = ClassroomDataKey(
      profileId: profileId,
      classroomId: classroomId,
    );
    if (key != _key) {
      _key = key;
      _state = const AsyncResource.idle();
    }
    final previous = _state;
    _state = previous.refreshing();
    notifyListeners();
    bool current() => !_disposed && revision == _revision && scope.isCurrent;
    try {
      final exercises = await _exerciseService.listExercises(
        classroomId: classroomId,
        profileId: profileId,
        visibility: 'PUBLIC',
      );
      if (!current()) return;
      _state = AsyncResource.ready(
        List.unmodifiable(exercises),
        updatedAt: DateTime.now(),
      );
    } catch (error) {
      if (!current()) return;
      _state = AsyncResource.failed(
        AppFailure.fromException(error),
        data: previous.data,
        hasData: previous.hasData,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    super.dispose();
  }
}
