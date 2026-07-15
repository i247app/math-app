import 'package:numi/core/localization/app_keys.dart';

enum HistoryFilter {
  homework(AppKeys.studentHomework),
  assessment(AppKeys.assessmentTab);

  const HistoryFilter(this.labelKey);

  final String labelKey;
}
