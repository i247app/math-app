import '../network/network.dart' as network;
import '../responses/profile/profile_create_response.dart';
import '../responses/profile/profile_fetch_response.dart';
import '../models/profile/update_profile_response.dart';
import '../models/profile/update_profile_request.dart';

class ProfileRepository {
  Future<ProfileCreateResponse> createProfile({
    required String uid,
    required String grade,
    required String level,
  }) async {
    final response = await network.createProfile(
      uid: uid,
      grade: grade,
      level: level,
    );
    return response;
  }

  Future<ProfileFetchResponse> fetchProfile(String uid) async {
    final response = await network.fetchProfile(uid);
    return response;
  }

  Future<UpdateProfileResponse> updateProfile(
    UpdateProfileRequest request,
  ) async {
    final response = await network.updateProfile(request);
    return response;
  }
}
