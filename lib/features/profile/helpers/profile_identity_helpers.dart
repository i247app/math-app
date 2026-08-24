import 'package:numi/features/profile/data/dto/profile_models.dart';

int? profileGradeStableId(StudentProfile? profile) {
  return profile?.grade?.gradeId ?? profile?.grade?.id ?? profile?.gradeId;
}
