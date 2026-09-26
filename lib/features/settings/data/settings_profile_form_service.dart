import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/profile_options_cache.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/data/school_service.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/profile_id_type_option.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/features/profile/models/semester.dart';
import 'package:numi/features/settings/helpers/settings_account_helpers.dart';
import 'package:numi/features/settings/helpers/settings_profile_helpers.dart';
import 'package:numi/features/settings/models/settings_profile_form.dart';

/// Loads form options and persists validated drafts without UI dependencies.
class SettingsProfileFormService {
  SettingsProfileFormService({
    required ProfileService profileService,
    required GradeService gradeService,
    required SchoolService schoolService,
    ProfileOptionsCache? optionsCache,
  }) : _profiles = profileService,
       _grades = gradeService,
       _schools = schoolService,
       _optionsCache = optionsCache ?? ProfileOptionsCache.instance;

  final ProfileService _profiles;
  final GradeService _grades;
  final SchoolService _schools;
  final ProfileOptionsCache _optionsCache;

  ProfileOptionsSnapshot? cachedOptions(int userId) =>
      _optionsCache.readFresh(userId: userId);

  Future<ProfileOptionsSnapshot> loadOptions(int userId) async {
    if (userId <= 0) {
      throw const SettingsProfileValidationException(
        AppKeys.profileOptionsMissingAccount,
      );
    }
    final cached = cachedOptions(userId);
    if (cached != null) return cached;

    late final List<SchoolModel> schools;
    late final List<GradeModel> grades;
    late final List<ProgramModel> programs;
    late final List<SemesterModel> semesters;
    // Wait for all four requests while keeping their results statically typed
    // and preserving the original API exception (rather than wrapping it).
    await Future.wait<void>([
      _schools.listSchools().then<void>((value) => schools = value),
      _grades.listGrades(userId: userId).then<void>((value) => grades = value),
      _profiles
          .listPrograms(userId: userId)
          .then<void>((value) => programs = value),
      _profiles
          .listSemesters(userId: userId)
          .then<void>((value) => semesters = value),
    ]);
    return _optionsCache.save(
      userId: userId,
      schools: schools,
      grades: grades,
      programs: programs,
      semesters: semesters,
    );
  }

  Future<SettingsProfileSaveResult> save(SettingsProfileDraft draft) async {
    final errorKey = draft.validationErrorKey;
    if (errorKey != null) throw SettingsProfileValidationException(errorKey);

    final name = draft.name.trim();
    final identifier = draft.identifier.trim();
    final teacherId =
        draft.isTeacher &&
            draft.normalizedIdType != null &&
            identifier.isNotEmpty
        ? identifier
        : null;
    final editingProfile = draft.editingProfile;
    if (editingProfile == null) {
      final created = await _profiles.createProfile(
        userId: draft.user!.id,
        schoolId: draft.schoolId!,
        name: name,
        gradeId: draft.isTeacher ? null : draft.gradeId!,
        programId: draft.isTeacher ? null : draft.programId!,
        semesterId: draft.isTeacher ? null : draft.semesterId!,
        isDefault: !draft.hasProfiles,
        role: draft.role,
        avatarKey: draft.avatarKey,
        idType: draft.isTeacher ? draft.normalizedIdType : profileIdTypeMoet,
        studentId: draft.isTeacher ? null : identifier,
        teacherId: teacherId,
      );
      return SettingsProfileSaveResult(
        requiresProfileRefresh: false,
        profileToActivate:
            (draft.role == 'STUDENT' || !draft.hasProfiles) &&
                profileStableId(created) != null
            ? created
            : null,
      );
    }

    if (draft.isParent) {
      await _profiles.updateProfile(
        profileId: editingProfile.profileId!,
        name: name,
        avatarKey: draft.avatarKey,
      );
    } else {
      await _profiles.updateProfile(
        profileId: editingProfile.profileId!,
        schoolId: draft.schoolId!,
        name: settingsEmptyToNull(name),
        gradeId: draft.isTeacher ? null : draft.gradeId,
        programId: draft.isTeacher ? null : draft.programId,
        semesterId: draft.isTeacher ? null : draft.semesterId,
        isDefault: editingProfile.isDefault,
        role: draft.role,
        dob: settingsProfileDateOnly(editingProfile.dob),
        avatarKey: draft.avatarKey,
        idType: draft.isTeacher ? draft.normalizedIdType : profileIdTypeMoet,
        studentId: draft.isTeacher ? null : identifier,
        teacherId: teacherId,
      );
    }
    return const SettingsProfileSaveResult(requiresProfileRefresh: true);
  }
}
