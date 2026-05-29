import '../../../core/config/api_config.dart';
import '../../../core/localization/app_keys.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/grade_models.dart';

class GradeException implements Exception {
  const GradeException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class GradeService {
  Future<List<GradeModel>> listGrades({required String userId});
}

class GradeApi implements GradeService {
  GradeApi({
    String? baseUrl,
    NetworkApi? networkApi,
  }) : _networkApi =
            networkApi ?? NetworkApi(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkApi _networkApi;

  @override
  Future<List<GradeModel>> listGrades({required String userId}) async {
    final cleanUserId = userId.trim();
    if (cleanUserId.isEmpty) {
      throw GradeException(AppStrings.current(AppKeys.noAccountForGrades));
    }

    final GradeListResponse response;
    try {
      response = await _networkApi.listGrades(
        GradeListRequest(userId: cleanUserId),
      );
    } on NetworkException catch (error) {
      throw GradeException(error.message, status: error.status);
    }

    return response.grades;
  }
}
