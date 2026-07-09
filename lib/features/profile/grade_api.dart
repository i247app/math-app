import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/network/grade_models.dart';

class GradeException implements Exception {
  const GradeException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class GradeService {
  Future<List<GradeModel>> listGrades({required int userId});
}

class GradeApi implements GradeService {
  GradeApi({String? baseUrl, NetworkApi? networkApi})
    : _networkApi =
          networkApi ??
          (baseUrl == null ? NetworkApi.shared : NetworkApi(baseUrl: baseUrl));

  final NetworkApi _networkApi;

  @override
  Future<List<GradeModel>> listGrades({required int userId}) async {
    if (userId <= 0) {
      throw GradeException(AppStrings.current(AppKeys.noAccountForGrades));
    }

    final GradeListResponse response;
    try {
      response = await _networkApi.listGrades(GradeListRequest(userId: userId));
    } on NetworkException catch (error) {
      throw GradeException(error.message, status: error.status);
    }

    return response.grades;
  }
}
