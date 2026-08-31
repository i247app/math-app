import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/profile/application/contracts/school_service.dart';
import 'package:numi/features/profile/data/dto/school_models.dart';
import 'package:numi/features/profile/errors/school_exception.dart';

class SchoolApi implements SchoolService {
  SchoolApi({String? baseUrl, NetworkClient? networkClient})
    : _networkClient =
          networkClient ??
          (baseUrl == null
              ? NetworkClient.shared
              : NetworkClient(baseUrl: baseUrl));

  final NetworkClient _networkClient;

  @override
  Future<List<SchoolModel>> listSchools() async {
    final json = await _networkClient.postJson(
      '/schools/list',
      const SchoolListRequest(takeAll: true).toJson(),
    );
    NetworkClient.throwForApiStatus(json);
    final response = SchoolListResponse.fromJson(json);

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
