import 'package:numi/features/home/application/contracts/home_layout_service.dart';
import 'package:numi/features/home/data/dto/home_layout_models.dart';
import 'package:numi/features/home/data/mappers/home_layout_mapper.dart';
import 'package:numi/features/home/domain/models/home_layout.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/home/application/errors/home_layout_exception.dart';

export 'package:numi/features/home/domain/models/home_layout.dart';

class HomeLayoutApi implements HomeLayoutService {
  HomeLayoutApi({String? baseUrl, NetworkClient? networkClient})
    : _networkClient =
          networkClient ??
          (baseUrl == null
              ? NetworkClient.shared
              : NetworkClient(baseUrl: baseUrl));

  final NetworkClient _networkClient;

  @override
  Future<HomeLayout> getLayout({required int profileId}) async {
    try {
      final json = await _networkClient.postJson(
        '/home/layout',
        <String, dynamic>{'profile_id': profileId},
      );
      final response = HomeLayoutResponseDto.fromJson(json);
      if (response.mstatus != 200) {
        throw HomeLayoutException(
          response.mmessage ??
              response.debug ??
              response.status ??
              'Request failed.',
          status: response.mstatus,
        );
      }
      final home = response.home;
      if (home == null) {
        throw const HomeLayoutException('Home layout is empty.');
      }
      return home.toDomain();
    } on NetworkException catch (error) {
      throw HomeLayoutException(error.message, status: error.status);
    }
  }
}
