import 'package:dio/dio.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/classroom/errors/classroom_exception.dart';

class ClassroomApi implements ClassroomService {
  ClassroomApi({String? baseUrl, NetworkClient? networkClient})
    : _remote = _ClassroomRemoteDataSource(
        networkClient ??
            (baseUrl == null
                ? NetworkClient.shared
                : NetworkClient(baseUrl: baseUrl)),
      );

  final _ClassroomRemoteDataSource _remote;

  @override
  Future<List<ClassroomModel>> listClassrooms({required int profileId}) async {
    try {
      final response = await _remote.listClassrooms(
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
      final response = await _remote.listMyJoinedClassrooms(
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
      final response = await _remote.listClassrooms(
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
      await _remote.joinClassroomByCode(
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
      final response = await _remote.listClassroomJoinRequests(
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
      final response = await _remote.listClassroomMembers(
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
      await _remote.approveClassroomJoinRequest(
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
      await _remote.rejectClassroomJoinRequest(
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
      await _remote.sendClassroomInvitations(
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
      final response = await _remote.listMyPendingClassroomInvitations(
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
      await _remote.acceptClassroomInvitation(
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
      await _remote.rejectClassroomInvitation(
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
      final response = await _remote.createClassroom(
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
      final response = await _remote.getClassroomDetail(
        classroomId: classroomId,
        profileId: profileId,
      );
      return response.classroom;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }
}

class _ClassroomRemoteDataSource {
  const _ClassroomRemoteDataSource(this._client);

  final NetworkClient _client;

  Future<ClassroomListResponse> listClassrooms(ClassroomListRequest request) =>
      _postResponse(
        '/classrooms/list',
        request.toJson(),
        ClassroomListResponse.fromJson,
      );

  Future<ClassroomListResponse> listMyJoinedClassrooms(
    ClassroomListRequest request,
  ) => _postResponse(
    '/classrooms/my-joined',
    request.toJson(),
    ClassroomListResponse.fromJson,
  );

  Future<ClassroomActionResponse> joinClassroomByCode(
    ClassroomJoinByCodeRequest request,
  ) => _action('/classrooms/join-by-code', request.toJson());

  Future<ClassroomMemberListResponse> listClassroomJoinRequests(
    ClassroomMembersListRequest request,
  ) => _postResponse(
    '/classrooms/join-requests/list',
    request.toJson(),
    ClassroomMemberListResponse.fromJson,
  );

  Future<ClassroomMemberListResponse> listClassroomMembers(
    ClassroomMembersListRequest request,
  ) => _postResponse(
    '/classrooms/members/list',
    request.toJson(),
    ClassroomMemberListResponse.fromJson,
  );

  Future<ClassroomActionResponse> approveClassroomJoinRequest(
    ClassroomJoinRequestActionRequest request,
  ) => _action('/classrooms/join-requests/approve', request.toJson());

  Future<ClassroomActionResponse> rejectClassroomJoinRequest(
    ClassroomJoinRequestActionRequest request,
  ) => _action('/classrooms/join-requests/reject', request.toJson());

  Future<ClassroomActionResponse> sendClassroomInvitations(
    ClassroomInvitationSendRequest request,
  ) => _action('/classrooms/invitations/send', request.toJson());

  Future<ClassroomInvitationListResponse> listMyPendingClassroomInvitations(
    ClassroomInvitationListRequest request,
  ) => _postResponse(
    '/classrooms/invitations/my-pending',
    request.toJson(),
    ClassroomInvitationListResponse.fromJson,
  );

  Future<ClassroomActionResponse> acceptClassroomInvitation(
    ClassroomInvitationActionRequest request,
  ) => _action('/classrooms/invitations/accept', request.toJson());

  Future<ClassroomActionResponse> rejectClassroomInvitation(
    ClassroomInvitationActionRequest request,
  ) => _action('/classrooms/invitations/reject', request.toJson());

  Future<ClassroomResponse> createClassroom(
    CreateClassroomRequest request, {
    String? filePath,
  }) async {
    final formData = FormData.fromMap({
      'profile_id': request.profileId,
      'name': request.name,
      'program_ids': request.programIds,
      'grade_id': request.gradeId,
      'school_id': request.schoolId,
      'max_members': request.maxMembers.toString(),
      if (request.description?.isNotEmpty == true)
        'description': request.description,
      if (filePath?.isNotEmpty == true)
        'file': await MultipartFile.fromFile(filePath!),
    });
    final json = await _client.postMultipart('/classrooms/create', formData);
    NetworkClient.throwForApiStatus(json);
    return ClassroomResponse.fromJson(json);
  }

  Future<ClassroomResponse> getClassroomDetail({
    required int classroomId,
    required int profileId,
  }) => _postResponse('/classrooms/detail', <String, dynamic>{
    'classroom_id': classroomId,
    'profile_id': profileId,
  }, ClassroomResponse.fromJson);

  Future<ClassroomActionResponse> _action(
    String path,
    Map<String, dynamic> body,
  ) => _postResponse(path, body, ClassroomActionResponse.fromJson);

  Future<T> _postResponse<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final json = await _client.postJson(path, body);
    NetworkClient.throwForApiStatus(json);
    return fromJson(json);
  }
}
