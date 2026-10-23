import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/classroom/controllers/classroom_state.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_exception.dart';

class ClassroomCubit extends Cubit<ClassroomState> {
  ClassroomCubit({required this._classroomService})
    : super(const ClassroomState());

  final ClassroomService _classroomService;
  final Map<String, Future<ClassroomCollectionState>> _pendingLoads =
      <String, Future<ClassroomCollectionState>>{};
  final Map<String, Future<ClassroomDetailState>> _pendingDetailLoads =
      <String, Future<ClassroomDetailState>>{};
  final Map<String, Future<ClassroomMembersState>> _pendingMemberLoads =
      <String, Future<ClassroomMembersState>>{};
  final Map<String, Object> _collectionTokens = {};
  final Map<String, Object> _detailTokens = {};
  final Map<String, Object> _memberTokens = {};
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
    if (isClosed) return Future.value(current);
    if (initialClassroom != null && current.classroom == null) {
      current = current.copyWith(classroom: initialClassroom);
      emit(state.replaceDetail(current));
    }
    if (!forceRefresh && current.hasLoaded && current.errorMessage == null) {
      return Future.value(current);
    }

    final requestKey = _classroomDataRequestKey(profileId, classroomId);
    final pending = _pendingDetailLoads[requestKey];
    if (pending != null) {
      return pending;
    }

    final token = Object();
    _detailTokens[requestKey] = token;
    final request = _performDetailLoad(
      profileId: profileId,
      classroomId: classroomId,
      generation: _generation,
      token: token,
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
    if (isClosed) return Future.value(current);
    if (!forceRefresh && current.hasLoaded && current.errorMessage == null) {
      return Future.value(current);
    }

    final requestKey = _classroomDataRequestKey(profileId, classroomId);
    final pending = _pendingMemberLoads[requestKey];
    if (pending != null) {
      return pending;
    }

    final token = Object();
    _memberTokens[requestKey] = token;
    final request = _performMembersLoad(
      profileId: profileId,
      classroomId: classroomId,
      generation: _generation,
      token: token,
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
    final generation = _generation;
    await _classroomService.approveJoinRequest(
      profileId: profileId,
      classroomId: classroomId,
      targetProfileId: targetProfileId,
    );
    if (isClosed || generation != _generation) return;
    invalidateClassroomData(
      profileId: profileId,
      classroomId: classroomId,
      detail: true,
      members: false,
    );
    _discardClassroomRequests(
      profileId,
      classroomId,
      detail: false,
      members: true,
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
    final generation = _generation;
    await _classroomService.rejectJoinRequest(
      profileId: profileId,
      classroomId: classroomId,
      targetProfileId: targetProfileId,
    );
    if (isClosed || generation != _generation) return;
    invalidateClassroomData(
      profileId: profileId,
      classroomId: classroomId,
      detail: true,
      members: false,
    );
    _discardClassroomRequests(
      profileId,
      classroomId,
      detail: false,
      members: true,
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
    final generation = _generation;
    await _classroomService.sendInvitations(
      inviterProfileId: inviterProfileId,
      classroomId: classroomId,
      targetProfileIds: targetProfileIds,
    );
    if (isClosed || generation != _generation) return;
    invalidateClassroomData(
      profileId: inviterProfileId,
      classroomId: classroomId,
    );
  }

  void invalidateOwned(int profileId) {
    if (isClosed) return;
    _discardCollection(ClassroomCollectionType.owned, profileId);
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
    if (isClosed) return;
    _discardCollection(ClassroomCollectionType.joined, profileId);
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
    if (isClosed) return;
    _discardClassroomRequests(
      profileId,
      classroomId,
      detail: detail,
      members: members,
    );
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
    if (isClosed) return Future.value(current);
    if (!forceRefresh && current.hasLoaded && current.errorMessage == null) {
      return Future.value(current);
    }

    final requestKey = '${type.name}:$profileId';
    final pending = _pendingLoads[requestKey];
    if (pending != null) {
      return pending;
    }

    final token = Object();
    _collectionTokens[requestKey] = token;
    final request = _performLoad(type, profileId, _generation, token);
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
    Object token,
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
      if (!_canApply(
        _collectionTokens,
        '${type.name}:$profileId',
        token,
        generation,
      )) {
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
      if (!_canApply(
        _collectionTokens,
        '${type.name}:$profileId',
        token,
        generation,
      )) {
        return state.collection(type, profileId);
      }
      return _emitFailure(type, current, error.message);
    } catch (error) {
      if (!_canApply(
        _collectionTokens,
        '${type.name}:$profileId',
        token,
        generation,
      )) {
        return state.collection(type, profileId);
      }
      return _emitFailure(type, current, error.toString());
    }
  }

  Future<ClassroomDetailState> _performDetailLoad({
    required int profileId,
    required int classroomId,
    required int generation,
    required Object token,
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
      if (!_canApply(
        _detailTokens,
        _classroomDataRequestKey(profileId, classroomId),
        token,
        generation,
      )) {
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
      if (!_canApply(
        _detailTokens,
        _classroomDataRequestKey(profileId, classroomId),
        token,
        generation,
      )) {
        return state.detail(profileId, classroomId);
      }
      return _emitDetailFailure(current, error.message);
    } catch (error) {
      if (!_canApply(
        _detailTokens,
        _classroomDataRequestKey(profileId, classroomId),
        token,
        generation,
      )) {
        return state.detail(profileId, classroomId);
      }
      return _emitDetailFailure(current, error.toString());
    }
  }

  Future<ClassroomMembersState> _performMembersLoad({
    required int profileId,
    required int classroomId,
    required int generation,
    required Object token,
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
      if (!_canApply(
        _memberTokens,
        _classroomDataRequestKey(profileId, classroomId),
        token,
        generation,
      )) {
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
      if (!_canApply(
        _memberTokens,
        _classroomDataRequestKey(profileId, classroomId),
        token,
        generation,
      )) {
        return state.members(profileId, classroomId);
      }
      return _emitMembersFailure(current, error.message);
    } catch (error) {
      if (!_canApply(
        _memberTokens,
        _classroomDataRequestKey(profileId, classroomId),
        token,
        generation,
      )) {
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
      errorMessage: message.trim().isEmpty ? 'classroom_load_failed' : message,
    );
    emit(state.replaceMembers(failed));
    return failed;
  }

  void invalidateProfile(int profileId) {
    if (isClosed) return;
    _discardCollection(ClassroomCollectionType.owned, profileId);
    _discardCollection(ClassroomCollectionType.joined, profileId);
    _discardClassroomRequests(profileId, null);
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

  bool _canApply(
    Map<String, Object> tokens,
    String key,
    Object token,
    int generation,
  ) => !isClosed && generation == _generation && identical(tokens[key], token);

  void _discardCollection(ClassroomCollectionType type, int profileId) {
    final key = '${type.name}:$profileId';
    _collectionTokens.remove(key);
    _pendingLoads.remove(key);
  }

  void _discardClassroomRequests(
    int profileId,
    int? classroomId, {
    bool detail = true,
    bool members = true,
  }) {
    bool matches(String key) => classroomId == null
        ? key.startsWith('$profileId:')
        : key == _classroomDataRequestKey(profileId, classroomId);
    if (detail) {
      _detailTokens.removeWhere((key, _) => matches(key));
      _pendingDetailLoads.removeWhere((key, _) => matches(key));
    }
    if (members) {
      _memberTokens.removeWhere((key, _) => matches(key));
      _pendingMemberLoads.removeWhere((key, _) => matches(key));
    }
  }

  void _discardAllRequests() {
    _generation++;
    _pendingLoads.clear();
    _pendingDetailLoads.clear();
    _pendingMemberLoads.clear();
    _collectionTokens.clear();
    _detailTokens.clear();
    _memberTokens.clear();
  }

  void clear() {
    if (isClosed) return;
    _discardAllRequests();
    emit(const ClassroomState());
  }

  @override
  Future<void> close() {
    _discardAllRequests();
    return super.close();
  }

  String _classroomDataRequestKey(int profileId, int classroomId) {
    return '$profileId:$classroomId';
  }
}
