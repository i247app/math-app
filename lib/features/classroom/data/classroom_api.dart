import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/classroom/errors/classroom_exception.dart';

abstract class ClassroomService {
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

class ClassroomApi implements ClassroomService {
  ClassroomApi({String? baseUrl, NetworkApi? networkApi})
    : _networkApi =
          networkApi ??
          (baseUrl == null ? NetworkApi.shared : NetworkApi(baseUrl: baseUrl));

  final NetworkApi _networkApi;

  @override
  Future<List<ClassroomModel>> listClassrooms({required int profileId}) async {
    try {
      final response = await _networkApi.listClassrooms(
        ClassroomListRequest(profileId: profileId, ownerProfileId: profileId),
      );
      return response.classrooms;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<List<ClassroomModel>> listMyJoinedClassrooms({
    required int profileId,
  }) async {
    try {
      final response = await _networkApi.listMyJoinedClassrooms(
        ClassroomListRequest(profileId: profileId),
      );
      return response.classrooms;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<List<ClassroomModel>> searchClassrooms({
    required int profileId,
    String? search,
    List<int>? gradeIds,
    List<int>? schoolIds,
  }) async {
    try {
      final response = await _networkApi.listClassrooms(
        ClassroomListRequest(
          profileId: profileId,
          search: search?.trim().isEmpty == true ? null : search?.trim(),
          gradeIds: gradeIds?.isEmpty == true ? null : gradeIds,
          schoolIds: schoolIds?.isEmpty == true ? null : schoolIds,
        ),
      );
      final selectedGradeIds = gradeIds?.toSet() ?? const <int>{};
      final selectedSchoolIds = schoolIds?.toSet() ?? const <int>{};

      return response.classrooms
          .where((classroom) {
            final matchesGrade =
                selectedGradeIds.isEmpty ||
                (classroom.gradeId != null &&
                    selectedGradeIds.contains(classroom.gradeId));
            final matchesSchool =
                selectedSchoolIds.isEmpty ||
                (classroom.schoolId != null &&
                    selectedSchoolIds.contains(classroom.schoolId));
            return matchesGrade && matchesSchool;
          })
          .toList(growable: false);
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<void> joinClassroomByCode({
    required int profileId,
    required String classroomCode,
  }) async {
    try {
      await _networkApi.joinClassroomByCode(
        ClassroomJoinByCodeRequest(
          profileId: profileId,
          classroomCode: classroomCode,
        ),
      );
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<List<ClassroomStudent>> listJoinRequests({
    required int profileId,
    required int classroomId,
  }) async {
    try {
      final response = await _networkApi.listClassroomJoinRequests(
        ClassroomMembersListRequest(
          profileId: profileId,
          classroomId: classroomId,
        ),
      );
      return response.members;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<List<ClassroomStudent>> listStudents({
    required int profileId,
    required int classroomId,
  }) async {
    try {
      final response = await _networkApi.listClassroomMembers(
        ClassroomMembersListRequest(
          profileId: profileId,
          classroomId: classroomId,
          role: 'STUDENT',
          status: 'ACTIVE',
        ),
      );
      return response.members;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<void> approveJoinRequest({
    required int profileId,
    required int classroomId,
    required int targetProfileId,
  }) async {
    try {
      await _networkApi.approveClassroomJoinRequest(
        ClassroomJoinRequestActionRequest(
          profileId: profileId,
          classroomId: classroomId,
          targetProfileId: targetProfileId,
        ),
      );
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<void> rejectJoinRequest({
    required int profileId,
    required int classroomId,
    required int targetProfileId,
  }) async {
    try {
      await _networkApi.rejectClassroomJoinRequest(
        ClassroomJoinRequestActionRequest(
          profileId: profileId,
          classroomId: classroomId,
          targetProfileId: targetProfileId,
        ),
      );
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<void> sendInvitations({
    required int inviterProfileId,
    required int classroomId,
    required List<int> targetProfileIds,
  }) async {
    try {
      await _networkApi.sendClassroomInvitations(
        ClassroomInvitationSendRequest(
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
          targets: targetProfileIds,
        ),
      );
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<List<ClassroomInvitation>> listMyPendingInvitations({
    required int profileId,
  }) async {
    try {
      final response = await _networkApi.listMyPendingClassroomInvitations(
        ClassroomInvitationListRequest(profileId: profileId),
      );
      return response.invitations;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<void> acceptInvitation({
    required int inviteeProfileId,
    required int inviterProfileId,
    required int classroomId,
  }) async {
    try {
      await _networkApi.acceptClassroomInvitation(
        ClassroomInvitationActionRequest(
          inviteeProfileId: inviteeProfileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        ),
      );
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<void> rejectInvitation({
    required int inviteeProfileId,
    required int inviterProfileId,
    required int classroomId,
  }) async {
    try {
      await _networkApi.rejectClassroomInvitation(
        ClassroomInvitationActionRequest(
          inviteeProfileId: inviteeProfileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        ),
      );
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<ClassroomModel?> createClassroom({
    required int profileId,
    required String name,
    required List<int> programIds,
    required int gradeId,
    required int schoolId,
    int maxMembers = 50,
    String? description,
    String? filePath,
  }) async {
    try {
      final response = await _networkApi.createClassroom(
        CreateClassroomRequest(
          profileId: profileId,
          name: name,
          programIds: programIds,
          gradeId: gradeId,
          schoolId: schoolId,
          maxMembers: maxMembers,
          description: description,
        ),
        filePath: filePath,
      );
      return response.classroom;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<ClassroomModel?> getClassroomDetail({
    required int classroomId,
    required int profileId,
  }) async {
    try {
      final response = await _networkApi.getClassroomDetail(
        classroomId: classroomId,
        profileId: profileId,
      );
      return response.classroom;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }
}
