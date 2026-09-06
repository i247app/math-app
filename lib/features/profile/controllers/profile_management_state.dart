import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/features/profile/models/semester.dart';

class ProfileManagementState {
  const ProfileManagementState({
    this.profiles = const <StudentProfile>[],
    this.activeProfileId,
    this.schools = const <SchoolModel>[],
    this.grades = const <GradeModel>[],
    this.programs = const <ProgramModel>[],
    this.semesters = const <SemesterModel>[],
    this.isLoadingProfiles = false,
    this.isLoadingOptions = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  final List<StudentProfile> profiles;
  final int? activeProfileId;
  final List<SchoolModel> schools;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final List<SemesterModel> semesters;
  final bool isLoadingProfiles;
  final bool isLoadingOptions;
  final bool isSaving;
  final bool isDeleting;
  final String? errorMessage;

  ProfileManagementState copyWith({
    List<StudentProfile>? profiles,
    int? activeProfileId,
    List<SchoolModel>? schools,
    List<GradeModel>? grades,
    List<ProgramModel>? programs,
    List<SemesterModel>? semesters,
    bool? isLoadingProfiles,
    bool? isLoadingOptions,
    bool? isSaving,
    bool? isDeleting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileManagementState(
      profiles: profiles ?? this.profiles,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      schools: schools ?? this.schools,
      grades: grades ?? this.grades,
      programs: programs ?? this.programs,
      semesters: semesters ?? this.semesters,
      isLoadingProfiles: isLoadingProfiles ?? this.isLoadingProfiles,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
