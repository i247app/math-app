import 'package:numi/features/quiz/widgets/history_tab/history_date_parts.dart';
import 'package:numi/features/quiz/helpers/two_digits.dart';

HistoryDateParts historyDatePartsFromIso(String? isoDate) {
  if (isoDate == null || isoDate.trim().isEmpty) {
    return const HistoryDateParts(date: '--/--/----', time: '--:--');
  }

  final parsed = DateTime.tryParse(isoDate)?.toLocal();
  if (parsed == null) {
    return HistoryDateParts(date: isoDate, time: '--:--');
  }

  return HistoryDateParts(
    date: '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}',
    time: '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)}',
  );
}
