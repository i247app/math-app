import 'package:numi/features/profile/domain/models/program.dart';
import 'package:numi/features/profile/domain/models/school.dart';
import 'package:numi/features/profile/domain/models/semester.dart';

class StudentProfile {
  const StudentProfile({
    this.id,
    this.profileId,
    this.profileCode,
    this.userId,
    this.schoolId,
    this.school,
    this.name,
    this.avatarKey,
    this.avatarUrl,
    this.dob,
    this.gradeId,
    this.grade,
    this.programId,
    this.program,
    this.semesterId,
    this.semester,
    this.isDefault = false,
    this.role,
    this.profileStatus,
    this.idType,
    this.studentId,
    this.teacherId,
    this.createDt,
    this.modifyDt,
  });

  final int? id;
  final int? profileId;
  final String? profileCode;
  final int? userId;
  final int? schoolId;
  final SchoolModel? school;
  final String? name;
  final String? avatarKey;
  final String? avatarUrl;
  final String? dob;
  final int? gradeId;
  final ProfileGrade? grade;
  final int? programId;
  final ProgramModel? program;
  final int? semesterId;
  final SemesterModel? semester;
  final bool isDefault;
  final String? role;
  final String? profileStatus;
  final String? idType;
  final String? studentId;
  final String? teacherId;
  final String? createDt;
  final String? modifyDt;
}

class ProfileGrade {
  const ProfileGrade({
    this.id,
    this.gradeId,
    this.label,
    this.description,
    this.displayOrder,
    this.imageUrl,
  });

  final int? id;
  final int? gradeId;
  final String? label;
  final String? description;
  final int? displayOrder;
  final String? imageUrl;
}
