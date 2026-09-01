import 'package:numi/features/classroom/domain/models/classroom.dart';

enum ClassroomCollectionType { owned, joined }

class ClassroomCollectionState {
  const ClassroomCollectionState({
    required this.profileId,
    this.classrooms = const <ClassroomModel>[],
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
  });

  final int profileId;
  final List<ClassroomModel> classrooms;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  ClassroomCollectionState copyWith({
    List<ClassroomModel>? classrooms,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClassroomCollectionState(
      profileId: profileId,
      classrooms: classrooms ?? this.classrooms,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ClassroomDataKey {
  const ClassroomDataKey({required this.profileId, required this.classroomId});

  final int profileId;
  final int classroomId;

  @override
  bool operator ==(Object other) {
    return other is ClassroomDataKey &&
        other.profileId == profileId &&
        other.classroomId == classroomId;
  }

  @override
  int get hashCode => Object.hash(profileId, classroomId);
}

class ClassroomDetailState {
  const ClassroomDetailState({
    required this.profileId,
    required this.classroomId,
    this.classroom,
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
  });

  final int profileId;
  final int classroomId;
  final ClassroomModel? classroom;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  ClassroomDetailState copyWith({
    ClassroomModel? classroom,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    bool clearClassroom = false,
    bool clearError = false,
  }) {
    return ClassroomDetailState(
      profileId: profileId,
      classroom: clearClassroom ? null : classroom ?? this.classroom,
      classroomId: classroomId,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ClassroomMembersState {
  const ClassroomMembersState({
    required this.profileId,
    required this.classroomId,
    this.joinRequests = const <ClassroomStudent>[],
    this.members = const <ClassroomStudent>[],
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
  });

  final int profileId;
  final int classroomId;
  final List<ClassroomStudent> joinRequests;
  final List<ClassroomStudent> members;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  ClassroomMembersState copyWith({
    List<ClassroomStudent>? joinRequests,
    List<ClassroomStudent>? members,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClassroomMembersState(
      profileId: profileId,
      classroomId: classroomId,
      joinRequests: joinRequests ?? this.joinRequests,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ClassroomState {
  const ClassroomState({
    this.ownedByProfile = const <int, ClassroomCollectionState>{},
    this.joinedByProfile = const <int, ClassroomCollectionState>{},
    this.detailByClassroom = const <ClassroomDataKey, ClassroomDetailState>{},
    this.membersByClassroom = const <ClassroomDataKey, ClassroomMembersState>{},
  });

  final Map<int, ClassroomCollectionState> ownedByProfile;
  final Map<int, ClassroomCollectionState> joinedByProfile;
  final Map<ClassroomDataKey, ClassroomDetailState> detailByClassroom;
  final Map<ClassroomDataKey, ClassroomMembersState> membersByClassroom;

  ClassroomCollectionState collection(
    ClassroomCollectionType type,
    int profileId,
  ) {
    final collections = switch (type) {
      ClassroomCollectionType.owned => ownedByProfile,
      ClassroomCollectionType.joined => joinedByProfile,
    };
    return collections[profileId] ??
        ClassroomCollectionState(profileId: profileId);
  }

  ClassroomDetailState detail(int profileId, int classroomId) {
    return detailByClassroom[ClassroomDataKey(
          profileId: profileId,
          classroomId: classroomId,
        )] ??
        ClassroomDetailState(profileId: profileId, classroomId: classroomId);
  }

  ClassroomMembersState members(int profileId, int classroomId) {
    return membersByClassroom[ClassroomDataKey(
          profileId: profileId,
          classroomId: classroomId,
        )] ??
        ClassroomMembersState(profileId: profileId, classroomId: classroomId);
  }

  ClassroomState replace(
    ClassroomCollectionType type,
    ClassroomCollectionState collection,
  ) {
    final owned = Map<int, ClassroomCollectionState>.of(ownedByProfile);
    final joined = Map<int, ClassroomCollectionState>.of(joinedByProfile);
    switch (type) {
      case ClassroomCollectionType.owned:
        owned[collection.profileId] = collection;
      case ClassroomCollectionType.joined:
        joined[collection.profileId] = collection;
    }
    return ClassroomState(
      ownedByProfile: Map.unmodifiable(owned),
      joinedByProfile: Map.unmodifiable(joined),
      detailByClassroom: detailByClassroom,
      membersByClassroom: membersByClassroom,
    );
  }

  ClassroomState replaceDetail(ClassroomDetailState detail) {
    final details = Map<ClassroomDataKey, ClassroomDetailState>.of(
      detailByClassroom,
    );
    details[ClassroomDataKey(
          profileId: detail.profileId,
          classroomId: detail.classroomId,
        )] =
        detail;
    return ClassroomState(
      ownedByProfile: ownedByProfile,
      joinedByProfile: joinedByProfile,
      detailByClassroom: Map.unmodifiable(details),
      membersByClassroom: membersByClassroom,
    );
  }

  ClassroomState replaceMembers(ClassroomMembersState members) {
    final memberStates = Map<ClassroomDataKey, ClassroomMembersState>.of(
      membersByClassroom,
    );
    memberStates[ClassroomDataKey(
          profileId: members.profileId,
          classroomId: members.classroomId,
        )] =
        members;
    return ClassroomState(
      ownedByProfile: ownedByProfile,
      joinedByProfile: joinedByProfile,
      detailByClassroom: detailByClassroom,
      membersByClassroom: Map.unmodifiable(memberStates),
    );
  }

  ClassroomState removeClassroomData({
    required int profileId,
    int? classroomId,
    bool detail = true,
    bool members = true,
  }) {
    final details = Map<ClassroomDataKey, ClassroomDetailState>.of(
      detailByClassroom,
    );
    final memberStates = Map<ClassroomDataKey, ClassroomMembersState>.of(
      membersByClassroom,
    );
    bool matches(ClassroomDataKey key) {
      return key.profileId == profileId &&
          (classroomId == null || key.classroomId == classroomId);
    }

    if (detail) {
      details.removeWhere((key, _) => matches(key));
    }
    if (members) {
      memberStates.removeWhere((key, _) => matches(key));
    }

    return ClassroomState(
      ownedByProfile: ownedByProfile,
      joinedByProfile: joinedByProfile,
      detailByClassroom: Map.unmodifiable(details),
      membersByClassroom: Map.unmodifiable(memberStates),
    );
  }
}
