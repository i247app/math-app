import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/profile/domain/models/program.dart';
import 'package:numi/features/profile/domain/models/semester.dart';

abstract interface class ProfileService {
  Future<List<StudentProfile>> listProfiles({required int userId});

  Future<List<StudentProfile>> searchProfiles({required String search});

  Future<List<ProgramModel>> listPrograms({required int userId});

  Future<List<SemesterModel>> listSemesters({required int userId});

  Future<StudentProfile?> createProfile({
    required int userId,
    required int schoolId,
    required String name,
    int? gradeId,
    int? programId,
    int? semesterId,
    bool isDefault = false,
    String role = 'STUDENT',
    String? avatarPath,
    String? avatarKey,
    String? dob,
    String? idType,
    String? studentId,
    String? teacherId,
  });

  Future<StudentProfile?> updateProfile({
    required int profileId,
    int? schoolId,
    String? name,
    int? gradeId,
    int? programId,
    int? semesterId,
    bool? isDefault,
    String? role,
    String? avatarPath,
    String? avatarKey,
    String? dob,
    String? idType,
    String? studentId,
    String? teacherId,
  });

  Future<void> forceDeleteProfile({required int profileId});
}
