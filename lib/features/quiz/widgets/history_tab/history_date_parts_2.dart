part of '../../history_tab.dart';

_HistoryDateParts _historyDateParts(String? isoDate) {
  if (isoDate == null || isoDate.trim().isEmpty) {
    return const _HistoryDateParts(date: '--/--/----', time: '--:--');
  }

  final parsed = DateTime.tryParse(isoDate)?.toLocal();
  if (parsed == null) {
    return _HistoryDateParts(date: isoDate, time: '--:--');
  }

  return _HistoryDateParts(
    date:
        '${_twoDigits(parsed.day)}/${_twoDigits(parsed.month)}/${parsed.year}',
    time: '${_twoDigits(parsed.hour)}:${_twoDigits(parsed.minute)}',
  );
}
