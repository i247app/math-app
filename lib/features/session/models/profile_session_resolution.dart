import 'package:numi/features/profile/models/profile.dart';

class ProfileSessionResolution {
  const ProfileSessionResolution({
    required this.profiles,
    required this.activeProfile,
    this.errorMessage,
  });

  const ProfileSessionResolution.empty()
    : profiles = const <UserProfile>[],
      activeProfile = null,
      errorMessage = null;

  final List<UserProfile> profiles;
  final UserProfile? activeProfile;
  final String? errorMessage;
}
