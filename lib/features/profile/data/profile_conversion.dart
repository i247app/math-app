import 'package:numi/features/profile/data/grade_api_models.dart';
import 'package:numi/features/profile/data/profile_api_models.dart';
import 'package:numi/features/profile/data/program_api_models.dart';
import 'package:numi/features/profile/data/school_api_models.dart';
import 'package:numi/features/profile/data/semester_api_models.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/features/profile/models/semester.dart';

extension GradeDtoConversion on GradeDto {
  GradeModel toModel() => GradeModel(
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

extension SchoolDtoConversion on SchoolDto {
  SchoolModel toModel() => SchoolModel(
    id: id,
    schoolId: schoolId,
    name: name,
    imageUrl: imageUrl,
    createDt: createDt,
    modifyDt: modifyDt,
  );
}

extension ProgramDtoConversion on ProgramDto {
  ProgramModel toModel() => ProgramModel(
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

extension SemesterDtoConversion on SemesterDto {
  SemesterModel toModel() => SemesterModel(
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

extension ProfileGradeDtoConversion on ProfileGradeDto {
  ProfileGrade toModel() => ProfileGrade(
    id: id,
    gradeId: gradeId,
    label: label,
    description: description,
    displayOrder: displayOrder,
    imageUrl: imageUrl,
  );
}

extension StudentProfileDtoConversion on StudentProfileDto {
  StudentProfile toModel() => StudentProfile(
    id: id,
    profileId: profileId,
    profileCode: profileCode,
    userId: userId,
    schoolId: schoolId,
    school: school?.toModel(),
    name: name,
    avatarKey: avatarKey,
    avatarUrl: avatarUrl,
    dob: dob,
    gradeId: gradeId,
    grade: grade?.toModel(),
    programId: programId,
    program: program?.toModel(),
    semesterId: semesterId,
    semester: semester?.toModel(),
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
