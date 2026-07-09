import 'package:numi/core/network/profile_models.dart';

class AuthProfileResolution {
  const AuthProfileResolution({
    required this.profiles,
    required this.activeProfile,
    this.errorMessage,
  });

  const AuthProfileResolution.empty()
    : profiles = const <StudentProfile>[],
      activeProfile = null,
      errorMessage = null;

  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? errorMessage;
}
