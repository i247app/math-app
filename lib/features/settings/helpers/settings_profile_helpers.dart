import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/profile/models/profile_id_type_option.dart';
import 'package:numi/features/profile/models/profile_role.dart';

T? settingsFirstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}

String? settingsProfileDateOnly(String? value) {
  final date = value?.trim();
  if (date == null || date.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(date);
  if (parsed == null) {
    return date.length >= 10 ? date.substring(0, 10) : date;
  }
  return parsed.toIso8601String().substring(0, 10);
}

String settingsProfileRole(StudentProfile profile) {
  final role = profile.role?.trim().toUpperCase();
  return switch (role) {
    'TEACHER' || 'PARENT' || 'STUDENT' => role!,
    _ => 'STUDENT',
  };
}

String settingsProfileFormRole({
  required LoginUser? user,
  StudentProfile? editingProfile,
}) {
  if (editingProfile != null) {
    return settingsProfileRole(editingProfile);
  }

  final userRole = user?.role?.trim().toUpperCase();
  return userRole == 'TEACHER' ? 'TEACHER' : 'STUDENT';
}

bool settingsCanCreateProfile({
  required LoginUser? user,
  required List<StudentProfile> profiles,
}) {
  final userRole = user?.role?.trim().toUpperCase();
  if (userRole == 'STUDENT' || userRole?.endsWith('_STUDENT') == true) {
    return false;
  }
  if (userRole == 'PARENT' ||
      userRole == 'TEACHER' ||
      userRole?.endsWith('_PARENT') == true ||
      userRole?.endsWith('_TEACHER') == true) {
    return true;
  }

  return profiles.any(
    (profile) => ProfileRole.fromProfile(profile) != ProfileRole.student,
  );
}

String? settingsNormalizedProfileIdType(String? value, String role) {
  final normalized = value?.trim().toUpperCase();
  if (role != 'TEACHER' && (normalized == null || normalized.isEmpty)) {
    return profileIdTypeMoet;
  }
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  final allowedOptions = role == 'TEACHER'
      ? teacherProfileIdTypeOptions
      : studentProfileIdTypeOptions;
  final isAllowed = allowedOptions.any((option) => option.value == normalized);
  return isAllowed ? normalized : null;
}
