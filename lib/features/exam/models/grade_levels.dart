import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/data/exam_exception.dart';

class GradeLevels {
  const GradeLevels({required this.latestLevel, required this.maxLevel});

  final int latestLevel;
  final int maxLevel;

  factory GradeLevels.fromJson(Map<String, dynamic> json) {
    final latestLevel = json['latest_level'];
    final maxLevel = json['max_level'];
    if (latestLevel is! int || maxLevel is! int) {
      throw ExamException(AppStrings.current(AppKeys.invalidServerResponse));
    }
    return GradeLevels(latestLevel: latestLevel, maxLevel: maxLevel);
  }
}
