import 'package:numi/core/helpers/api_date_time.dart';

DateTime historyDateValue(String? value) {
  return tryParseApiDateTime(value?.trim() ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
