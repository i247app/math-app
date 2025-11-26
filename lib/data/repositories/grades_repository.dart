import '../network/network.dart' as network;
import '../responses/grades/grades_list_response.dart';

class GradesRepository {
  Future<GradesListResponse> getGradesList() async {
    final response = await network.getGradesList();
    return response;
  }
}
