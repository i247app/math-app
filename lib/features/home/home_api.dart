import 'package:numi_flutter/core/network/home_layout_models.dart';
import 'package:numi_flutter/core/network/network_client.dart';

export 'package:numi_flutter/core/network/home_layout_models.dart';

class HomeLayoutException implements Exception {
  const HomeLayoutException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class HomeLayoutService {
  Future<HomeLayout> getLayout({required int profileId});
}

class HomeLayoutApi implements HomeLayoutService {
  HomeLayoutApi({
    String? baseUrl,
    NetworkClient? networkClient,
  }) : _networkClient = networkClient ?? NetworkClient(baseUrl: baseUrl);

  final NetworkClient _networkClient;

  @override
  Future<HomeLayout> getLayout({required int profileId}) async {
    try {
      final json = await _networkClient.postJson(
        '/home/layout',
        <String, dynamic>{'profile_id': profileId},
      );
      final response = HomeLayoutResponse.fromJson(json);
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
      return home;
    } on NetworkException catch (error) {
      throw HomeLayoutException(error.message, status: error.status);
    }
  }
}
