import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/profile/domain/models/profile_role.dart';

class ActiveProfileResolution {
  const ActiveProfileResolution({
    required this.profiles,
    required this.activeProfile,
  });

  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;

  ProfileRole get role => ProfileRole.fromProfile(activeProfile);

  int? get activeProfileId => profileStableId(activeProfile);
}
