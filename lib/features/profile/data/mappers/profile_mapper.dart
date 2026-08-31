import 'package:numi/features/profile/data/dto/grade_models.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/data/dto/program_models.dart';
import 'package:numi/features/profile/data/dto/school_models.dart';
import 'package:numi/features/profile/data/dto/semester_models.dart';
import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/profile/domain/models/program.dart';
import 'package:numi/features/profile/domain/models/school.dart';
import 'package:numi/features/profile/domain/models/semester.dart';

extension GradeDtoMapper on GradeDto {
  GradeModel toDomain() => GradeModel(
    id: id,
    gradeId: gradeId,
    label: label,
    description: description,
    displayOrder: displayOrder,
    imageUrl: imageUrl,
    createDt: createDt,
    modifyDt: modifyDt,
  );
}

extension SchoolDtoMapper on SchoolDto {
  SchoolModel toDomain() => SchoolModel(
    id: id,
    schoolId: schoolId,
    name: name,
    imageUrl: imageUrl,
    createDt: createDt,
    modifyDt: modifyDt,
  );
}

extension ProgramDtoMapper on ProgramDto {
  ProgramModel toDomain() => ProgramModel(
    id: id,
    programId: programId,
    label: label,
    description: description,
    displayOrder: displayOrder,
    imageUrl: imageUrl,
    createDt: createDt,
    modifyDt: modifyDt,
  );
}

extension SemesterDtoMapper on SemesterDto {
  SemesterModel toDomain() => SemesterModel(
    id: id,
    semesterId: semesterId,
    name: name,
    description: description,
    displayOrder: displayOrder,
    imageUrl: imageUrl,
    createDt: createDt,
    modifyDt: modifyDt,
  );
}

extension ProfileGradeDtoMapper on ProfileGradeDto {
  ProfileGrade toDomain() => ProfileGrade(
    id: id,
    gradeId: gradeId,
    label: label,
    description: description,
    displayOrder: displayOrder,
    imageUrl: imageUrl,
  );
}

extension StudentProfileDtoMapper on StudentProfileDto {
  StudentProfile toDomain() => StudentProfile(
    id: id,
    profileId: profileId,
    profileCode: profileCode,
    userId: userId,
    schoolId: schoolId,
    school: school?.toDomain(),
    name: name,
    avatarKey: avatarKey,
    avatarUrl: avatarUrl,
    dob: dob,
    gradeId: gradeId,
    grade: grade?.toDomain(),
    programId: programId,
    program: program?.toDomain(),
    semesterId: semesterId,
    semester: semester?.toDomain(),
    isDefault: isDefault,
    role: role,
    profileStatus: profileStatus,
    idType: idType,
    studentId: studentId,
    teacherId: teacherId,
    createDt: createDt,
    modifyDt: modifyDt,
  );
}
