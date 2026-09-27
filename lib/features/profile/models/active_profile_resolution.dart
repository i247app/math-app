import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/profile_role.dart';

class ActiveProfileResolution {
  const ActiveProfileResolution({
    required this.profiles,
    required this.activeProfile,
  });

  final List<UserProfile> profiles;
  final UserProfile? activeProfile;

  ProfileRole get role => ProfileRole.fromProfile(activeProfile);

  int? get activeProfileId => profileStableId(activeProfile);
}
