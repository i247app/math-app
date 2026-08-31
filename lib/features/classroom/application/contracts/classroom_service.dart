import 'package:numi/features/classroom/data/dto/classroom_models.dart';

abstract interface class ClassroomService {
  Future<List<ClassroomModel>> listClassrooms({required int profileId});

  Future<List<ClassroomModel>> listMyJoinedClassrooms({required int profileId});

  Future<List<ClassroomModel>> searchClassrooms({
    required int profileId,
    String? search,
    List<int>? gradeIds,
    List<int>? schoolIds,
  });

  Future<void> joinClassroomByCode({
    required int profileId,
    required String classroomCode,
  });

  Future<List<ClassroomStudent>> listJoinRequests({
    required int profileId,
    required int classroomId,
  });

  Future<List<ClassroomStudent>> listStudents({
    required int profileId,
    required int classroomId,
  });

  Future<void> approveJoinRequest({
    required int profileId,
    required int classroomId,
    required int targetProfileId,
  });

  Future<void> rejectJoinRequest({
    required int profileId,
    required int classroomId,
    required int targetProfileId,
  });

  Future<void> sendInvitations({
    required int inviterProfileId,
    required int classroomId,
    required List<int> targetProfileIds,
  });

  Future<List<ClassroomInvitation>> listMyPendingInvitations({
    required int profileId,
  });

  Future<void> acceptInvitation({
    required int inviteeProfileId,
    required int inviterProfileId,
    required int classroomId,
  });

  Future<void> rejectInvitation({
    required int inviteeProfileId,
    required int inviterProfileId,
    required int classroomId,
  });

  Future<ClassroomModel?> createClassroom({
    required int profileId,
    required String name,
    required List<int> programIds,
    required int gradeId,
    required int schoolId,
    int maxMembers = 50,
    String? description,
    String? filePath,
  });

  Future<ClassroomModel?> getClassroomDetail({
    required int classroomId,
    required int profileId,
  });
}
