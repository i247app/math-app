part of '../../history_tab.dart';

_HistoryDateParts _historyDatePartsFromIso(String? isoDate) {
  if (isoDate == null || isoDate.trim().isEmpty) {
    return const _HistoryDateParts(date: '--/--/----', time: '--:--');
  }

  final parsed = DateTime.tryParse(isoDate)?.toLocal();
  if (parsed == null) {
    return _HistoryDateParts(date: isoDate, time: '--:--');
  }

  return _HistoryDateParts(
    date:
        '${_historyTwoDigits(parsed.day)}/${_historyTwoDigits(parsed.month)}/${parsed.year}',
    time:
        '${_historyTwoDigits(parsed.hour)}:${_historyTwoDigits(parsed.minute)}',
  );
}
