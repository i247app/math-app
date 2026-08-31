import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/profile/data/dto/grade_models.dart';
import 'package:numi/features/profile/data/dto/program_models.dart';
import 'package:numi/features/profile/data/dto/school_models.dart';
import 'package:numi/features/profile/data/dto/semester_models.dart';
import 'package:numi/features/profile/application/profile_management_state.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/profile/application/contracts/school_service.dart';

class ProfileManagementCubit extends Cubit<ProfileManagementState> {
  ProfileManagementCubit({
    required ProfileService profileService,
    required GradeService gradeService,
    required SchoolService schoolService,
    ActiveProfileSession activeProfileSession = const ActiveProfileSession(),
  }) : _profileService = profileService,
       _gradeService = gradeService,
       _schoolService = schoolService,
       _activeProfileSession = activeProfileSession,
       super(const ProfileManagementState());

  final ProfileService _profileService;
  final GradeService _gradeService;
  final SchoolService _schoolService;
  final ActiveProfileSession _activeProfileSession;

  Future<void> loadProfiles(int userId) async {
    if (userId <= 0) {
      return;
    }
    emit(state.copyWith(isLoadingProfiles: true, clearError: true));
    try {
      final profiles = await _profileService.listProfiles(userId: userId);
      final activeProfileId = await _activeProfileSession.readActiveProfileId(
        userId,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            profiles: profiles,
            activeProfileId: activeProfileId,
            isLoadingProfiles: false,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoadingProfiles: false,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> loadOptions(int userId) async {
    if (userId <= 0 || state.isLoadingOptions) {
      return;
    }
    emit(state.copyWith(isLoadingOptions: true, clearError: true));
    try {
      final results = await Future.wait<Object>([
        _schoolService.listSchools(),
        _gradeService.listGrades(userId: userId),
        _profileService.listPrograms(userId: userId),
        _profileService.listSemesters(userId: userId),
      ]);
      if (!isClosed) {
        emit(
          state.copyWith(
            schools: results[0] as List<SchoolModel>,
            grades: results[1] as List<GradeModel>,
            programs: results[2] as List<ProgramModel>,
            semesters: results[3] as List<SemesterModel>,
            isLoadingOptions: false,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoadingOptions: false,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }
}
