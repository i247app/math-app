import 'package:numi_flutter/core/network/classroom_models.dart';

enum ClassroomCollectionType {
  owned,
  joined,
}

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

class ClassroomState {
  const ClassroomState({
    this.ownedByProfile = const <int, ClassroomCollectionState>{},
    this.joinedByProfile = const <int, ClassroomCollectionState>{},
  });

  final Map<int, ClassroomCollectionState> ownedByProfile;
  final Map<int, ClassroomCollectionState> joinedByProfile;

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
    );
  }
}
