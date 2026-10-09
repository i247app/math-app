import 'package:numi/core/helpers/api_date_time.dart';
import 'package:numi/features/exam/models/exam.dart';

String examReviewTimeLabel(GeneratedExam exam) {
  final parsed = tryParseApiDateTime(
    exam.modifyDt ?? exam.createDt ?? '',
  )?.toLocal();
  if (parsed == null) {
    return '--:--';
  }
  return '${_twoDigits(parsed.hour)}:${_twoDigits(parsed.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
