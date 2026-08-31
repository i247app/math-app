enum ClassroomRelationship {
  member,
  pendingInvitation,
  pendingRequest,
  none,
  unknown;

  static ClassroomRelationship fromWire(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'MEMBER' => ClassroomRelationship.member,
      'PENDING_INVITATION' => ClassroomRelationship.pendingInvitation,
      'PENDING_REQUEST' => ClassroomRelationship.pendingRequest,
      'NONE' => ClassroomRelationship.none,
      _ => ClassroomRelationship.unknown,
    };
  }
}

class ClassroomModel {
  const ClassroomModel({
    this.id,
    this.classroomId,
    this.profileId,
    this.name,
    this.description,
    this.programId,
    this.programIds = const <int>[],
    this.gradeId,
    this.schoolId,
    this.classroomCode,
    this.owner,
    this.ownerProfileId,
    this.relationship,
    this.teacherName,
    this.programName,
    this.schoolName,
    this.maxMembers,
    this.memberCount,
    this.studentCount,
    this.teacherCount,
    this.pendingRequestCount,
    this.students = const <ClassroomStudent>[],
    this.imageUrl,
    this.avatarUrl,
    this.fileUrl,
    this.createDt,
    this.modifyDt,
  });

  final int? id;
  final int? classroomId;
  final int? profileId;
  final String? name;
  final String? description;
  final int? programId;
  final List<int> programIds;
  final int? gradeId;
  final int? schoolId;
  final String? classroomCode;
  final ClassroomOwner? owner;
  final int? ownerProfileId;
  final String? relationship;
  final String? teacherName;
  final String? programName;
  final String? schoolName;
  final int? maxMembers;
  final int? memberCount;
  final int? studentCount;
  final int? teacherCount;
  final int? pendingRequestCount;
  final List<ClassroomStudent> students;
  final String? imageUrl;
  final String? avatarUrl;
  final String? fileUrl;
  final String? createDt;
  final String? modifyDt;

  int? get stableId => classroomId ?? id;
  int get displayStudentCount =>
      studentCount ?? (students.isNotEmpty ? students.length : 0);
  int get displayMemberCount => memberCount ?? displayStudentCount;
  int get displayPendingRequestCount => pendingRequestCount ?? 0;
  ClassroomRelationship get relationshipStatus =>
      ClassroomRelationship.fromWire(relationship);
}

class ClassroomOwner {
  const ClassroomOwner({
    this.profileId,
    this.name,
    this.role,
    this.avatarUrl,
    this.imageUrl,
    this.fileUrl,
  });

  final int? profileId;
  final String? name;
  final String? role;
  final String? avatarUrl;
  final String? imageUrl;
  final String? fileUrl;
}

class ClassroomStudent {
  const ClassroomStudent({
    this.id,
    this.profileId,
    this.name,
    this.avatarKey,
    this.avatarUrl,
    this.joinedAt,
    this.status,
    this.role,
  });

  final int? id;
  final int? profileId;
  final String? name;
  final String? avatarKey;
  final String? avatarUrl;
  final String? joinedAt;
  final String? status;
  final String? role;
}

class ClassroomInvitation {
  const ClassroomInvitation({
    this.id,
    this.invitationId,
    this.classroomId,
    this.inviterProfileId,
    this.inviterName,
    this.status,
    this.createdAt,
    this.classroom,
  });

  final int? id;
  final int? invitationId;
  final int? classroomId;
  final int? inviterProfileId;
  final String? inviterName;
  final String? status;
  final String? createdAt;
  final ClassroomModel? classroom;

  int? get stableClassroomId => classroomId ?? classroom?.stableId;
}
