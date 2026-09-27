import 'package:numi/features/profile/models/profile.dart';

int? profileGradeStableId(UserProfile? profile) {
  return profile?.grade?.gradeId ?? profile?.grade?.id ?? profile?.gradeId;
}
