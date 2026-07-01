part of '../../history_tab.dart';

enum _HistoryFilter {
  homework(AppKeys.studentHomework),
  assessment(AppKeys.assessmentTab);

  const _HistoryFilter(this.labelKey);

  final String labelKey;
}
