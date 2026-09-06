import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/grade_api_models.dart';
import 'package:numi/features/profile/data/profile_conversion.dart';
import 'package:numi/features/profile/data/grade_exception.dart';
import 'package:numi/features/profile/models/grade.dart';

class GradeApi implements GradeService {
  GradeApi({String? baseUrl, NetworkClient? networkClient})
    : _networkClient =
          networkClient ??
          (baseUrl == null
              ? NetworkClient.shared
              : NetworkClient(baseUrl: baseUrl));

  final NetworkClient _networkClient;

  @override
  Future<List<GradeModel>> listGrades({required int userId}) async {
    if (userId <= 0) {
      throw GradeException(AppStrings.current(AppKeys.noAccountForGrades));
    }

    final GradeListResponse response;
    try {
      final json = await _networkClient.postJson(
        '/grades/list',
        GradeListRequest(userId: userId).toJson(),
      );
      NetworkClient.throwForApiStatus(json);
      response = GradeListResponse.fromJson(json);
    } on NetworkException catch (error) {
      throw GradeException(error.message, status: error.status);
    }

    return response.grades.map((grade) => grade.toModel()).toList();
  }
}
