import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/network/school_models.dart';

class SchoolException implements Exception {
  const SchoolException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class SchoolService {
  Future<List<SchoolModel>> listSchools();
}

class SchoolApi implements SchoolService {
  SchoolApi({String? baseUrl, NetworkApi? networkApi})
    : _networkApi =
          networkApi ??
          (baseUrl == null ? NetworkApi.shared : NetworkApi(baseUrl: baseUrl));

  final NetworkApi _networkApi;

  @override
  Future<List<SchoolModel>> listSchools() async {
    final response = await _networkApi.listSchools(
      const SchoolListRequest(takeAll: true),
    );

    if (response.mstatus != 200) {
      throw SchoolException(
        response.mmessage ??
            response.debug ??
            response.status ??
            'Request failed.',
        status: response.mstatus,
      );
    }

    return response.schools;
  }
}
