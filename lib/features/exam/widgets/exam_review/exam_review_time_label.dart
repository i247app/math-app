import 'package:numi/core/helpers/api_date_time.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/helpers/two_digits.dart';

String examReviewTimeLabel(GeneratedExam exam) {
  final parsed = tryParseApiDateTime(
    exam.modifyDt ?? exam.createDt ?? '',
  )?.toLocal();
  if (parsed == null) {
    return '--:--';
  }
  return '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)}';
}
