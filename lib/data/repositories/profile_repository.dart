import '../network/network.dart' as network;
import '../responses/profile/profile_create_response.dart';
import '../responses/profile/profile_fetch_response.dart';
import '../responses/update_profile/update_profile_response.dart';
import '../models/profile/update_profile_request.dart';

class ProfileRepository {
  Future<ProfileCreateResponse> createProfile({
    required String uid,
    required String gradeId,
    required String semesterId,
  }) async {
    final response = await network.createProfile(
      uid: uid,
      gradeId: gradeId,
      semesterId: semesterId,
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

  Future<UpdateProfileResponse> updateProfileWithFormData({
    required String uid,
    String? gradeId,
    String? semesterId,
    String? avatarPath,
  }) async {
    final response = await network.updateProfileWithFormData(
      uid: uid,
      gradeId: gradeId,
      semesterId: semesterId,
      avatarPath: avatarPath,
    );
    return response;
  }
}
