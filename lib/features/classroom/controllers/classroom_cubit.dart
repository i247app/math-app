import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/classroom/controllers/classroom_state.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_exception.dart';

class ClassroomCubit extends Cubit<ClassroomState> {
  ClassroomCubit({required ClassroomService classroomService})
    : _classroomService = classroomService,
      super(const ClassroomState());

  final ClassroomService _classroomService;
  final Map<String, Future<ClassroomCollectionState>> _pendingLoads =
      <String, Future<ClassroomCollectionState>>{};
  final Map<String, Future<ClassroomDetailState>> _pendingDetailLoads =
      <String, Future<ClassroomDetailState>>{};
  final Map<String, Future<ClassroomMembersState>> _pendingMemberLoads =
      <String, Future<ClassroomMembersState>>{};
  int _generation = 0;

  ClassroomCollectionState owned(int profileId) {
    return state.collection(ClassroomCollectionType.owned, profileId);
  }

  ClassroomCollectionState joined(int profileId) {
    return state.collection(ClassroomCollectionType.joined, profileId);
  }

  ClassroomDetailState detail({
    required int profileId,
    required int classroomId,
  }) {
    return state.detail(profileId, classroomId);
  }

  ClassroomMembersState members({
    required int profileId,
    required int classroomId,
  }) {
    return state.members(profileId, classroomId);
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

  Future<ClassroomDetailState> loadDetail({
    required int profileId,
    required int classroomId,
    ClassroomModel? initialClassroom,
    bool forceRefresh = false,
  }) {
    var current = state.detail(profileId, classroomId);
    if (initialClassroom != null && current.classroom == null) {
      current = current.copyWith(classroom: initialClassroom);
      emit(state.replaceDetail(current));
    }
    if (!forceRefresh && current.hasLoaded) {
      return Future.value(current);
    }

    final requestKey = _classroomDataRequestKey(profileId, classroomId);
    final pending = _pendingDetailLoads[requestKey];
    if (pending != null) {
      return pending;
    }

    final request = _performDetailLoad(
      profileId: profileId,
      classroomId: classroomId,
      generation: _generation,
    );
    _pendingDetailLoads[requestKey] = request;
    return request.whenComplete(() {
      if (identical(_pendingDetailLoads[requestKey], request)) {
        _pendingDetailLoads.remove(requestKey);
      }
    });
  }

  Future<ClassroomMembersState> loadMembers({
    required int profileId,
    required int classroomId,
    bool forceRefresh = false,
  }) {
    final current = state.members(profileId, classroomId);
    if (!forceRefresh && current.hasLoaded) {
      return Future.value(current);
    }

    final requestKey = _classroomDataRequestKey(profileId, classroomId);
    final pending = _pendingMemberLoads[requestKey];
    if (pending != null) {
      return pending;
    }

    final request = _performMembersLoad(
      profileId: profileId,
      classroomId: classroomId,
      generation: _generation,
    );
    _pendingMemberLoads[requestKey] = request;
    return request.whenComplete(() {
      if (identical(_pendingMemberLoads[requestKey], request)) {
        _pendingMemberLoads.remove(requestKey);
      }
    });
  }

  Future<void> approveJoinRequest({
    required int profileId,
    required int classroomId,
    required int targetProfileId,
  }) async {
    await _classroomService.approveJoinRequest(
      profileId: profileId,
      classroomId: classroomId,
      targetProfileId: targetProfileId,
    );
    invalidateClassroomData(
      profileId: profileId,
      classroomId: classroomId,
      detail: true,
      members: false,
    );
    await loadMembers(
      profileId: profileId,
      classroomId: classroomId,
      forceRefresh: true,
    );
  }

  Future<void> rejectJoinRequest({
    required int profileId,
    required int classroomId,
    required int targetProfileId,
  }) async {
    await _classroomService.rejectJoinRequest(
      profileId: profileId,
      classroomId: classroomId,
      targetProfileId: targetProfileId,
    );
    invalidateClassroomData(
      profileId: profileId,
      classroomId: classroomId,
      detail: true,
      members: false,
    );
    await loadMembers(
      profileId: profileId,
      classroomId: classroomId,
      forceRefresh: true,
    );
  }

  Future<void> sendInvitations({
    required int inviterProfileId,
    required int classroomId,
    required List<int> targetProfileIds,
  }) async {
    await _classroomService.sendInvitations(
      inviterProfileId: inviterProfileId,
      classroomId: classroomId,
      targetProfileIds: targetProfileIds,
    );
    invalidateClassroomData(
      profileId: inviterProfileId,
      classroomId: classroomId,
    );
  }

  void invalidateOwned(int profileId) {
    final owned = Map<int, ClassroomCollectionState>.of(state.ownedByProfile)
      ..remove(profileId);
    emit(
      ClassroomState(
        ownedByProfile: Map.unmodifiable(owned),
        joinedByProfile: state.joinedByProfile,
        detailByClassroom: state.detailByClassroom,
        membersByClassroom: state.membersByClassroom,
      ),
    );
  }

  void invalidateJoined(int profileId) {
    final joined = Map<int, ClassroomCollectionState>.of(state.joinedByProfile)
      ..remove(profileId);
    emit(
      ClassroomState(
        ownedByProfile: state.ownedByProfile,
        joinedByProfile: Map.unmodifiable(joined),
        detailByClassroom: state.detailByClassroom,
        membersByClassroom: state.membersByClassroom,
      ),
    );
  }

  void invalidateClassroomData({
    required int profileId,
    int? classroomId,
    bool detail = true,
    bool members = true,
  }) {
    emit(
      state.removeClassroomData(
        profileId: profileId,
        classroomId: classroomId,
        detail: detail,
        members: members,
      ),
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
      state.replace(type, current.copyWith(isLoading: true, clearError: true)),
    );

    try {
      final classrooms = switch (type) {
        ClassroomCollectionType.owned => await _classroomService.listClassrooms(
          profileId: profileId,
        ),
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

  Future<ClassroomDetailState> _performDetailLoad({
    required int profileId,
    required int classroomId,
    required int generation,
  }) async {
    final current = state.detail(profileId, classroomId);
    emit(
      state.replaceDetail(current.copyWith(isLoading: true, clearError: true)),
    );

    try {
      final classroom = await _classroomService.getClassroomDetail(
        classroomId: classroomId,
        profileId: profileId,
      );
      if (generation != _generation) {
        return state.detail(profileId, classroomId);
      }
      final loaded = ClassroomDetailState(
        profileId: profileId,
        classroomId: classroomId,
        classroom: classroom ?? current.classroom,
        hasLoaded: true,
      );
      emit(state.replaceDetail(loaded));
      return loaded;
    } on ClassroomException catch (error) {
      if (generation != _generation) {
        return state.detail(profileId, classroomId);
      }
      return _emitDetailFailure(current, error.message);
    } catch (error) {
      if (generation != _generation) {
        return state.detail(profileId, classroomId);
      }
      return _emitDetailFailure(current, error.toString());
    }
  }

  Future<ClassroomMembersState> _performMembersLoad({
    required int profileId,
    required int classroomId,
    required int generation,
  }) async {
    final current = state.members(profileId, classroomId);
    emit(
      state.replaceMembers(current.copyWith(isLoading: true, clearError: true)),
    );

    try {
      final results = await Future.wait([
        _classroomService.listJoinRequests(
          profileId: profileId,
          classroomId: classroomId,
        ),
        _classroomService.listStudents(
          profileId: profileId,
          classroomId: classroomId,
        ),
      ]);
      if (generation != _generation) {
        return state.members(profileId, classroomId);
      }
      final loaded = ClassroomMembersState(
        profileId: profileId,
        classroomId: classroomId,
        joinRequests: List.unmodifiable(results[0]),
        members: List.unmodifiable(results[1]),
        hasLoaded: true,
      );
      emit(state.replaceMembers(loaded));
      return loaded;
    } on ClassroomException catch (error) {
      if (generation != _generation) {
        return state.members(profileId, classroomId);
      }
      return _emitMembersFailure(current, error.message);
    } catch (error) {
      if (generation != _generation) {
        return state.members(profileId, classroomId);
      }
      return _emitMembersFailure(current, error.toString());
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

  ClassroomDetailState _emitDetailFailure(
    ClassroomDetailState current,
    String message,
  ) {
    final failed = current.copyWith(
      isLoading: false,
      hasLoaded: true,
      errorMessage: message.trim().isEmpty ? 'classroom_load_failed' : message,
    );
    emit(state.replaceDetail(failed));
    return failed;
  }

  ClassroomMembersState _emitMembersFailure(
    ClassroomMembersState current,
    String message,
  ) {
    final failed = current.copyWith(
      isLoading: false,
      hasLoaded: true,
      errorMessage: message.trim().isEmpty ? 'classroom_load_failed' : message,
    );
    emit(state.replaceMembers(failed));
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
        detailByClassroom: state
            .removeClassroomData(profileId: profileId)
            .detailByClassroom,
        membersByClassroom: state
            .removeClassroomData(profileId: profileId)
            .membersByClassroom,
      ),
    );
  }

  void clear() {
    _generation++;
    _pendingLoads.clear();
    _pendingDetailLoads.clear();
    _pendingMemberLoads.clear();
    emit(const ClassroomState());
  }

  String _classroomDataRequestKey(int profileId, int classroomId) {
    return '$profileId:$classroomId';
  }
}
