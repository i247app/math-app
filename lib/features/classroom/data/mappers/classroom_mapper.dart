import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/classroom/domain/models/classroom.dart';

extension ClassroomOwnerDtoMapper on ClassroomOwnerDto {
  ClassroomOwner toDomain() => ClassroomOwner(
    profileId: profileId,
    name: name,
    role: role,
    avatarUrl: avatarUrl,
    imageUrl: imageUrl,
    fileUrl: fileUrl,
  );
}

extension ClassroomStudentDtoMapper on ClassroomStudentDto {
  ClassroomStudent toDomain() => ClassroomStudent(
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

extension ClassroomDtoMapper on ClassroomDto {
  ClassroomModel toDomain() => ClassroomModel(
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
    owner: owner?.toDomain(),
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
    students: students.map((student) => student.toDomain()).toList(),
    imageUrl: imageUrl,
    avatarUrl: avatarUrl,
    fileUrl: fileUrl,
    createDt: createDt,
    modifyDt: modifyDt,
  );
}

extension ClassroomInvitationDtoMapper on ClassroomInvitationDto {
  ClassroomInvitation toDomain() => ClassroomInvitation(
    id: id,
    invitationId: invitationId,
    classroomId: classroomId,
    inviterProfileId: inviterProfileId,
    inviterName: inviterName,
    status: status,
    createdAt: createdAt,
    classroom: classroom?.toDomain(),
  );
}
