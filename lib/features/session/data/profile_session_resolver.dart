import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/data/profile_exception.dart';
import 'package:numi/features/session/models/profile_session_resolution.dart';

class ProfileSessionResolver {
  ProfileSessionResolver({
    required ProfileService profileService,
    required ActiveProfileSession activeProfileSession,
  }) : _profileService = profileService,
       _activeProfileSession = activeProfileSession;

  final ProfileService _profileService;
  final ActiveProfileSession _activeProfileSession;
  Future<void> _pendingStorage = Future<void>.value();

  Future<ProfileSessionResolution> resolveForUserId(
    int userId, {
    bool Function()? isCurrent,
  }) async {
    if (userId <= 0 || isCurrent?.call() == false) {
      return const ProfileSessionResolution.empty();
    }

    try {
      final profiles = await _profileService.listProfiles(userId: userId);
      return await _withStorage(() async {
        if (isCurrent?.call() == false) {
          return const ProfileSessionResolution.empty();
        }
        final activeProfile = await _activeProfileSession.resolveActiveProfile(
          userId: userId,
          profiles: profiles,
        );
        if (isCurrent?.call() == false) {
          return const ProfileSessionResolution.empty();
        }
        final activeProfileId = profileStableId(activeProfile);
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
      });
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
    bool Function()? isCurrent,
  }) async {
    final profileId = profileStableId(profile);
    if (userId <= 0 || profileId == null) {
      return;
    }
    await _withStorage(() async {
      if (isCurrent?.call() == false) return;
      await _activeProfileSession.writeActiveProfileId(
        userId: userId,
        profileId: profileId,
      );
    });
  }

  // Serialize reads with writes so a refresh cannot restore an older choice
  // while a newer selection is still being persisted. Failed writes must not
  // prevent later selections from being saved.
  Future<T> _withStorage<T>(Future<T> Function() operation) {
    final result = _pendingStorage.then((_) => operation());
    _pendingStorage = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }
}
