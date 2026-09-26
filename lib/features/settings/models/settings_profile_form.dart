import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/settings/helpers/settings_profile_helpers.dart';

/// A snapshot of the form values, independent of text controllers and widgets.
class SettingsProfileDraft {
  const SettingsProfileDraft({
    required this.user,
    required this.name,
    required this.hasProfiles,
    this.editingProfile,
    this.schoolId,
    this.gradeId,
    this.programId,
    this.semesterId,
    this.avatarKey,
    this.idType,
    this.identifier = '',
  });

  final LoginUser? user;
  final String name;
  final bool hasProfiles;
  final StudentProfile? editingProfile;
  final int? schoolId;
  final int? gradeId;
  final int? programId;
  final int? semesterId;
  final String? avatarKey;
  final String? idType;
  final String identifier;

  String get role =>
      settingsProfileFormRole(user: user, editingProfile: editingProfile);
  bool get isTeacher => role == 'TEACHER';
  bool get isParent => role == 'PARENT';
  bool get isUpdating => editingProfile != null;
  String? get normalizedIdType => settingsNormalizedProfileIdType(idType, role);

  /// Preserve the existing button readiness rules separately from submission
  /// validation, which also checks account and semester information.
  bool get canSave {
    if (name.trim().isEmpty) return false;
    if (isParent) return true;
    if (schoolId == null) return false;
    return isTeacher || (programId != null && gradeId != null);
  }

  String? get validationErrorKey {
    if (user == null || user!.id <= 0) return AppKeys.missingAccount;
    if ((!isUpdating || isParent) && name.trim().isEmpty) {
      return AppKeys.missingProfileName;
    }
    if (!isParent && schoolId == null) {
      return AppKeys.missingProfileSelections;
    }
    if (!isTeacher &&
        !isParent &&
        !isUpdating &&
        (gradeId == null || programId == null || semesterId == null)) {
      return AppKeys.missingProfileSelections;
    }
    if (isTeacher && normalizedIdType == null && identifier.trim().isNotEmpty) {
      return AppKeys.missingProfileSelections;
    }
    if (isUpdating && editingProfile!.profileId == null) {
      return AppKeys.missingProfileId;
    }
    return null;
  }
}

class SettingsProfileValidationException implements Exception {
  const SettingsProfileValidationException(this.errorKey);

  final String errorKey;
}

class SettingsProfileSaveResult {
  const SettingsProfileSaveResult({
    required this.requiresProfileRefresh,
    this.profileToActivate,
  });

  final bool requiresProfileRefresh;
  final StudentProfile? profileToActivate;
}
