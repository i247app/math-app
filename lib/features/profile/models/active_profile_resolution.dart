import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/services/active_profile_session.dart';

class ActiveProfileResolution {
  const ActiveProfileResolution({
    required this.profiles,
    required this.activeProfile,
  });

  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;

  ProfileRole get role => ProfileRole.fromProfile(activeProfile);

  int? get activeProfileId =>
      ActiveProfileSession.profileStableId(activeProfile);
}
