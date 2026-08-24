import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';

String displayTeacherName(StudentProfile? profile) {
  final name = profile?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  return AppStrings.current(AppKeys.teacherFallback);
}
