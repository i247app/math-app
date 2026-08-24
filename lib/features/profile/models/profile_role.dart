import 'package:numi/features/profile/data/dto/profile_models.dart';

enum ProfileRole {
  student,
  parent,
  teacher;

  static ProfileRole fromRole(String? value) {
    final role = value?.trim().toUpperCase();
    return switch (role) {
      'PARENT' => ProfileRole.parent,
      'TEACHER' => ProfileRole.teacher,
      _ => ProfileRole.student,
    };
  }

  static ProfileRole fromProfile(StudentProfile? profile) {
    return fromRole(profile?.role);
  }
}
