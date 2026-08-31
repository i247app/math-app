import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/data/mappers/classroom_exercise_mapper.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/homework/errors/classroom_exercise_exception.dart';

class ClassroomExerciseApi implements ClassroomExerciseService {
  ClassroomExerciseApi({String? baseUrl, NetworkClient? networkClient})
    : _remote = _ClassroomExerciseRemoteDataSource(
        networkClient ??
            (baseUrl == null
                ? NetworkClient.shared
                : NetworkClient(baseUrl: baseUrl)),
      );

  final _ClassroomExerciseRemoteDataSource _remote;

  @override
  Future<List<ClassroomExercise>> listExercises({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
    String? purpose,
  }) {
    return _runExerciseRequest(() async {
      final response = await _remote.listClassroomExercises(
        ClassroomExerciseListRequest(
          classroomId: classroomId,
          profileId: profileId,
          search: search?.trim().isEmpty == true ? null : search?.trim(),
          visibility: visibility?.trim().isEmpty == true
              ? null
              : visibility?.trim(),
          submissionStatus: submissionStatus?.trim().isEmpty == true
              ? null
              : submissionStatus?.trim(),
          purpose: purpose?.trim().isEmpty == true ? null : purpose?.trim(),
        ),
      );
      return response.exercises.map((exercise) => exercise.toDomain()).toList();
    });
  }

  @override
  Future<ClassroomExercise?> createExercise({
    required int profileId,
    required int classroomId,
    required int programId,
    required String title,
    required String description,
    required int numQuestions,
    required String chapterName,
    required String lessonName,
    required String visibility,
    required String startDate,
    required String endDate,
    String purpose = classroomExercisePurposeHomework,
  }) {
    return _runExerciseRequest(() async {
      final response = await _remote.createClassroomExercise(
        CreateClassroomExerciseRequest(
          profileId: profileId,
          classroomId: classroomId,
          programId: programId,
          title: title,
          description: description,
          numQuestions: numQuestions,
          chapterName: chapterName,
          lessonName: lessonName,
          visibility: visibility,
          startDate: startDate,
          endDate: endDate,
          purpose: purpose,
        ),
      );
      return response.exercise?.toDomain();
    });
  }

  @override
  Future<ClassroomExercise?> getExerciseDetail({
    required int exerciseId,
    required int profileId,
  }) {
    return _runExerciseRequest(() async {
      final response = await _remote.getClassroomExerciseDetail(
        exerciseId: exerciseId,
        profileId: profileId,
      );
      final exercise = response.exercise;
      if (exercise == null) {
        throw const ClassroomExerciseException('');
      }
      return exercise.toDomain();
    });
  }

  @override
  Future<ClassroomExercise?> updateExerciseVisibility({
    required int profileId,
    required int classroomExerciseId,
    required String visibility,
    String purpose = classroomExercisePurposeHomework,
  }) {
    return _runExerciseRequest(() async {
      final response = await _remote.updateClassroomExercise(
        UpdateClassroomExerciseRequest(
          profileId: profileId,
          classroomExerciseId: classroomExerciseId,
          visibility: visibility,
          purpose: purpose,
        ),
      );
      return response.exercise?.toDomain();
    });
  }

  @override
  Future<ClassroomExerciseSubmissionResponse> submitExercise({
    required int profileId,
    required int classroomExerciseId,
    required List<SubmitClassroomExerciseAnswer> answers,
  }) {
    return _runExerciseRequest(() {
      return _remote
          .submitClassroomExercise(
            SubmitClassroomExerciseRequest(
              profileId: profileId,
              classroomExerciseId: classroomExerciseId,
              answers: answers.map((answer) => answer.toDto()).toList(),
            ),
          )
          .then((response) => response.toDomain());
    });
  }
}

Future<T> _runExerciseRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on NetworkException catch (error) {
    throw ClassroomExerciseException(error.message, status: error.status);
  }
}

class _ClassroomExerciseRemoteDataSource {
  const _ClassroomExerciseRemoteDataSource(this._client);

  final NetworkClient _client;

  Future<ClassroomExerciseListResponse> listClassroomExercises(
    ClassroomExerciseListRequest request,
  ) => _postResponse(
    '/classroom-exercises/list',
    request.toJson(),
    ClassroomExerciseListResponse.fromJson,
  );

  Future<ClassroomExerciseResponse> createClassroomExercise(
    CreateClassroomExerciseRequest request,
  ) => _postResponse(
    '/classroom-exercises/create',
    request.toJson(),
    ClassroomExerciseResponse.fromJson,
  );

  Future<ClassroomExerciseResponse> updateClassroomExercise(
    UpdateClassroomExerciseRequest request,
  ) => _postResponse(
    '/classroom-exercises/update',
    request.toJson(),
    ClassroomExerciseResponse.fromJson,
  );

  Future<ClassroomExerciseSubmissionResponseDto> submitClassroomExercise(
    SubmitClassroomExerciseRequest request,
  ) => _postResponse(
    '/classroom-exercise/submissions/submit',
    request.toJson(),
    ClassroomExerciseSubmissionResponseDto.fromJson,
  );

  Future<ClassroomExerciseResponse> getClassroomExerciseDetail({
    required int exerciseId,
    int? profileId,
  }) => _postResponse('/classroom-exercises/detail', <String, dynamic>{
    'classroom_exercise_id': exerciseId,
    'profile_id': ?profileId,
  }, ClassroomExerciseResponse.fromJson);

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
