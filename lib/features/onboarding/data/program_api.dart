import '../../../core/config/api_config.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/program_models.dart';

class ProgramException implements Exception {
  const ProgramException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class ProgramService {
  Future<List<ProgramGrade>> listGrades({required String userId});
}

class FakeProgramApi implements ProgramService {
  const FakeProgramApi();

  @override
  Future<List<ProgramGrade>> listGrades({required String userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final response = ProgramListResponse.fromJson(_fakeProgramListResponse());
    if (response.mstatus != 200) {
      throw ProgramException(
        response.mmessage ?? response.debug ?? 'Tải danh sách lớp thất bại.',
        status: response.mstatus,
      );
    }

    return response.grades;
  }
}

class ProgramApi implements ProgramService {
  ProgramApi({
    String? baseUrl,
    NetworkApi? networkApi,
  }) : _networkApi =
            networkApi ?? NetworkApi(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkApi _networkApi;

  @override
  Future<List<ProgramGrade>> listGrades({required String userId}) async {
    final cleanUserId = userId.trim();
    if (cleanUserId.isEmpty) {
      throw const ProgramException('Thiếu user để tải danh sách lớp.');
    }

    final ProgramListResponse response;
    try {
      response = await _networkApi.listPrograms(
        ProgramListRequest(userId: cleanUserId),
      );
    } on NetworkException catch (error) {
      throw ProgramException(error.message, status: error.status);
    }

    return response.grades;
  }
}

Map<String, Object?> _fakeProgramListResponse() {
  return <String, Object?>{
    'mstatus': 200,
    'grades': <Object?>[
      _fakeGrade(11, 'a8885604-52a2-11f1-952f-0264f43b762f', 'Lớp 1', 1),
      _fakeGrade(12, 'a894d2f2-52a2-11f1-952f-0264f43b762f', 'Lớp 2', 2),
      _fakeGrade(13, 'a8956d9c-52a2-11f1-952f-0264f43b762f', 'Lớp 3', 3),
      _fakeGrade(14, 'a89570e5-52a2-11f1-952f-0264f43b762f', 'Lớp 4', 4),
      _fakeGrade(15, 'a8957199-52a2-11f1-952f-0264f43b762f', 'Lớp 5', 5),
    ],
    'pagination': <String, Object?>{
      'has_next': false,
      'has_previous': false,
      'page': 1,
      'size': 20,
      'skip': 0,
      'take_all': false,
      'total_count': 5,
      'total_pages': 1,
    },
    'status': 'Success',
  };
}

Map<String, Object?> _fakeGrade(
  int id,
  String gradeId,
  String label,
  int displayOrder,
) {
  return <String, Object?>{
    'create_dt': '2026-05-18T10:16:38.964284Z',
    'description': 'Chương trình học $label.',
    'display_order': displayOrder,
    'grade_id': gradeId,
    'id': id,
    'image_url': null,
    'label': label,
    'modify_dt': '2026-05-18T10:16:38.964284Z',
  };
}
