part of '../../history_tab.dart';

DateTime _historyDateValue(String? value) {
  return DateTime.tryParse(value?.trim() ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
