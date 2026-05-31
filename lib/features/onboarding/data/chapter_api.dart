import '../../../core/config/api_config.dart';
import '../../../core/network/chapter_models.dart';
import '../../../core/network/network_client.dart';

class ChapterException implements Exception {
  const ChapterException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class ChapterService {
  Future<List<ChapterModel>> listChapters({
    required int programId,
    required int gradeId,
    required int semesterId,
  });
}

class ChapterApi implements ChapterService {
  ChapterApi({
    String? baseUrl,
    NetworkApi? networkApi,
  }) : _networkApi =
            networkApi ?? NetworkApi(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkApi _networkApi;

  @override
  Future<List<ChapterModel>> listChapters({
    required int programId,
    required int gradeId,
    required int semesterId,
  }) async {
    try {
      final response = await _networkApi.listChapters(
        ChapterListRequest(
          programId: programId,
          gradeId: gradeId,
          semesterId: semesterId,
        ),
      );
      return response.chapters;
    } on NetworkException catch (error) {
      throw ChapterException(error.message, status: error.status);
    }
  }
}
