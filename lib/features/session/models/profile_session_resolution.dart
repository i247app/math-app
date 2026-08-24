import 'package:numi/features/profile/data/dto/profile_models.dart';

class ProfileSessionResolution {
  const ProfileSessionResolution({
    required this.profiles,
    required this.activeProfile,
    this.errorMessage,
  });

  const ProfileSessionResolution.empty()
    : profiles = const <StudentProfile>[],
      activeProfile = null,
      errorMessage = null;

  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? errorMessage;
}
