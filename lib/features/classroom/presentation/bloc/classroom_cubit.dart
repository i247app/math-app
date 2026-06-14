import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numi_flutter/features/classroom/classroom_api.dart';
import 'package:numi_flutter/features/classroom/presentation/bloc/classroom_state.dart';

class ClassroomCubit extends Cubit<ClassroomState> {
  ClassroomCubit({required ClassroomService classroomService})
      : _classroomService = classroomService,
        super(const ClassroomState());

  final ClassroomService _classroomService;
  final Map<String, Future<ClassroomCollectionState>> _pendingLoads =
      <String, Future<ClassroomCollectionState>>{};
  int _generation = 0;

  ClassroomCollectionState owned(int profileId) {
    return state.collection(ClassroomCollectionType.owned, profileId);
  }

  ClassroomCollectionState joined(int profileId) {
    return state.collection(ClassroomCollectionType.joined, profileId);
  }

  Future<ClassroomCollectionState> loadOwned(
    int profileId, {
    bool forceRefresh = false,
  }) {
    return _load(
      ClassroomCollectionType.owned,
      profileId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ClassroomCollectionState> loadJoined(
    int profileId, {
    bool forceRefresh = false,
  }) {
    return _load(
      ClassroomCollectionType.joined,
      profileId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ClassroomCollectionState> _load(
    ClassroomCollectionType type,
    int profileId, {
    required bool forceRefresh,
  }) {
    final current = state.collection(type, profileId);
    if (!forceRefresh && current.hasLoaded) {
      return Future.value(current);
    }

    final requestKey = '${type.name}:$profileId';
    final pending = _pendingLoads[requestKey];
    if (pending != null) {
      return pending;
    }

    final request = _performLoad(type, profileId, _generation);
    _pendingLoads[requestKey] = request;
    return request.whenComplete(() {
      if (identical(_pendingLoads[requestKey], request)) {
        _pendingLoads.remove(requestKey);
      }
    });
  }

  Future<ClassroomCollectionState> _performLoad(
    ClassroomCollectionType type,
    int profileId,
    int generation,
  ) async {
    final current = state.collection(type, profileId);
    emit(
      state.replace(
        type,
        current.copyWith(isLoading: true, clearError: true),
      ),
    );

    try {
      final classrooms = switch (type) {
        ClassroomCollectionType.owned =>
          await _classroomService.listClassrooms(profileId: profileId),
        ClassroomCollectionType.joined =>
          await _classroomService.listMyJoinedClassrooms(profileId: profileId),
      };
      if (generation != _generation) {
        return state.collection(type, profileId);
      }
      final loaded = ClassroomCollectionState(
        profileId: profileId,
        classrooms: List.unmodifiable(classrooms),
        hasLoaded: true,
      );
      emit(state.replace(type, loaded));
      return loaded;
    } on ClassroomException catch (error) {
      if (generation != _generation) {
        return state.collection(type, profileId);
      }
      return _emitFailure(type, current, error.message);
    } catch (error) {
      if (generation != _generation) {
        return state.collection(type, profileId);
      }
      return _emitFailure(type, current, error.toString());
    }
  }

  ClassroomCollectionState _emitFailure(
    ClassroomCollectionType type,
    ClassroomCollectionState current,
    String message,
  ) {
    final failed = current.copyWith(
      isLoading: false,
      hasLoaded: true,
      errorMessage: message.trim().isEmpty ? 'classroom_load_failed' : message,
    );
    emit(state.replace(type, failed));
    return failed;
  }

  void invalidateProfile(int profileId) {
    final owned = Map<int, ClassroomCollectionState>.of(state.ownedByProfile)
      ..remove(profileId);
    final joined = Map<int, ClassroomCollectionState>.of(state.joinedByProfile)
      ..remove(profileId);
    emit(
      ClassroomState(
        ownedByProfile: Map.unmodifiable(owned),
        joinedByProfile: Map.unmodifiable(joined),
      ),
    );
  }

  void clear() {
    _generation++;
    _pendingLoads.clear();
    emit(const ClassroomState());
  }
}
