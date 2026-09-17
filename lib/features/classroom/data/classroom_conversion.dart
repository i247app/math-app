import 'package:numi/features/classroom/data/classroom_api_models.dart';
import 'package:numi/features/classroom/models/classroom.dart';

extension ClassroomOwnerDtoConversion on ClassroomOwnerDto {
  ClassroomOwner toModel() => ClassroomOwner(
    profileId: profileId,
    name: name,
    role: role,
    avatarUrl: avatarUrl,
    imageUrl: imageUrl,
    fileUrl: fileUrl,
  );
}

extension ClassroomStudentDtoConversion on ClassroomStudentDto {
  ClassroomStudent toModel() => ClassroomStudent(
    id: id,
    profileId: profileId,
    name: name,
    avatarKey: avatarKey,
    avatarUrl: avatarUrl,
    joinedAt: joinedAt,
    status: status,
    role: role,
  );
}

extension ClassroomDtoConversion on ClassroomDto {
  ClassroomModel toModel() => ClassroomModel(
    id: id,
    classroomId: classroomId,
    profileId: profileId,
    name: name,
    description: description,
    programId: programId,
    programIds: programIds,
    gradeId: gradeId,
    schoolId: schoolId,
    classroomCode: classroomCode,
    owner: owner?.toModel(),
    ownerProfileId: ownerProfileId,
    relationship: relationship,
    teacherName: teacherName,
    programName: programName,
    schoolName: schoolName,
    maxMembers: maxMembers,
    memberCount: memberCount,
    studentCount: studentCount,
    teacherCount: teacherCount,
    pendingRequestCount: pendingRequestCount,
    students: students.map((student) => student.toModel()).toList(),
    imageUrl: imageUrl,
    avatarUrl: avatarUrl,
    fileUrl: fileUrl,
    createDt: createDt,
    modifyDt: modifyDt,
  );
}

extension ClassroomInvitationDtoConversion on ClassroomInvitationDto {
  ClassroomInvitation toModel() => ClassroomInvitation(
    id: id,
    invitationId: invitationId,
    classroomId: classroomId,
    inviterProfileId: inviterProfileId,
    inviterName: inviterName,
    status: status,
    createdAt: createdAt,
    classroom: classroom?.toModel(),
  );
}
