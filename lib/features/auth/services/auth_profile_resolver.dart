import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/auth/models/auth_profile_resolution.dart';
import 'package:numi/features/auth/otp_auth_api.dart';
import 'package:numi/features/profile/profile_api.dart';
import 'package:numi/features/profile/services/active_profile_session.dart';

class AuthProfileResolver {
  const AuthProfileResolver({
    required ProfileService profileService,
    required ActiveProfileSession activeProfileSession,
  }) : _profileService = profileService,
       _activeProfileSession = activeProfileSession;

  final ProfileService _profileService;
  final ActiveProfileSession _activeProfileSession;

  Future<AuthProfileResolution> resolveForUser(LoginUser user) async {
    final userId = user.id;
    if (userId <= 0) {
      return const AuthProfileResolution.empty();
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
      return AuthProfileResolution(
        profiles: profiles,
        activeProfile: activeProfile,
      );
    } on ProfileException catch (error) {
      return AuthProfileResolution(
        profiles: const <StudentProfile>[],
        activeProfile: null,
        errorMessage: error.message,
      );
    } catch (_) {
      return AuthProfileResolution(
        profiles: const <StudentProfile>[],
        activeProfile: null,
        errorMessage: AppStrings.current(AppKeys.profileLoadFailed),
      );
    }
  }

  Future<void> rememberActiveProfile({
    required LoginUser user,
    required StudentProfile profile,
  }) async {
    final profileId = ActiveProfileSession.profileStableId(profile);
    if (user.id <= 0 || profileId == null) {
      return;
    }

    await _activeProfileSession.writeActiveProfileId(
      userId: user.id,
      profileId: profileId,
    );
  }
}
