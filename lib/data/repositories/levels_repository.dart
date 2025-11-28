import '../network/network.dart' as network;
import '../responses/levels/levels_list_response.dart';

class LevelsRepository {
  Future<LevelsListResponse> getLevelsList() async {
    final response = await network.getLevelsList();
    return response;
  }
}
