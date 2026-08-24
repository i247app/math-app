import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/profile_exception.dart';
import 'package:numi/features/session/models/profile_session_resolution.dart';

class ProfileSessionResolver {
  const ProfileSessionResolver({
    required ProfileService profileService,
    required ActiveProfileSession activeProfileSession,
  }) : _profileService = profileService,
       _activeProfileSession = activeProfileSession;

  final ProfileService _profileService;
  final ActiveProfileSession _activeProfileSession;

  Future<ProfileSessionResolution> resolveForUserId(int userId) async {
    if (userId <= 0) {
      return const ProfileSessionResolution.empty();
    }

    try {
      final profiles = await _profileService.listProfiles(userId: userId);
      final activeProfile = await _activeProfileSession.resolveActiveProfile(
        userId: userId,
        profiles: profiles,
      );
      final activeProfileId = ActiveProfileSession.profileStableId(
        activeProfile,
      );
      if (activeProfileId != null) {
        await _activeProfileSession.writeActiveProfileId(
          userId: userId,
          profileId: activeProfileId,
        );
      } else {
        await _activeProfileSession.clearActiveProfileId(userId);
      }
      return ProfileSessionResolution(
        profiles: profiles,
        activeProfile: activeProfile,
      );
    } on ProfileException catch (error) {
      return ProfileSessionResolution(
        profiles: const <StudentProfile>[],
        activeProfile: null,
        errorMessage: error.message,
      );
    } catch (_) {
      return ProfileSessionResolution(
        profiles: const <StudentProfile>[],
        activeProfile: null,
        errorMessage: AppStrings.current(AppKeys.profileLoadFailed),
      );
    }
  }

  Future<void> rememberActiveProfile({
    required int userId,
    required StudentProfile profile,
  }) async {
    final profileId = ActiveProfileSession.profileStableId(profile);
    if (userId <= 0 || profileId == null) {
      return;
    }
    await _activeProfileSession.writeActiveProfileId(
      userId: userId,
      profileId: profileId,
    );
  }
}
