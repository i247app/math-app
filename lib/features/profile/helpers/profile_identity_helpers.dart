import 'package:numi/features/profile/models/profile.dart';

int? profileGradeStableId(StudentProfile? profile) {
  return profile?.grade?.gradeId ?? profile?.grade?.id ?? profile?.gradeId;
}
