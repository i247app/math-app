import 'package:numi/features/profile/models/profile.dart';

class GuestAccount {
  const GuestAccount({
    required this.uid,
    required this.user,
    this.profiles = const <StudentProfile>[],
  });

  final int uid;

  /// The complete user object returned by the guest API.
  final Map<String, dynamic> user;
  final List<StudentProfile> profiles;

  int? get profileId {
    for (final profile in profiles) {
      if (profile.isDefault && profile.stableId != null) {
        return profile.stableId;
      }
    }
    for (final profile in profiles) {
      if (profile.stableId != null) return profile.stableId;
    }

    final direct = _positiveInt(user['profile_id']);
    if (direct != null) return direct;

    final profile = user['profile'];
    if (profile is Map) {
      final profileMap = Map<String, dynamic>.from(profile);
      final id =
          _positiveInt(profileMap['profile_id']) ??
          _positiveInt(profileMap['id']);
      if (id != null) return id;
    }

    final userProfiles = user['profiles'];
    if (userProfiles is List) {
      for (final item in userProfiles) {
        if (item is! Map) continue;
        final profileMap = Map<String, dynamic>.from(item);
        final id =
            _positiveInt(profileMap['profile_id']) ??
            _positiveInt(profileMap['id']);
        if (id != null) return id;
      }
    }
    return null;
  }

  static int? positiveInt(Object? value) => _positiveInt(value);

  static int? _positiveInt(Object? value) {
    final number = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '');
    return number != null && number > 0 ? number : null;
  }
}
