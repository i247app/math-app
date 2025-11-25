import 'package:json_annotation/json_annotation.dart';
import 'time_utils.dart';

class UtcTimestampConverter implements JsonConverter<DateTime?, String?> {
  const UtcTimestampConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null) {
      return null;
    }
    return TimeUtils.parseCustomTimestamp(json);
  }

  @override
  String? toJson(DateTime? object) {
    if (object == null) {
      return null;
    }
    return "${object.toIso8601String().replaceAll('-', '').replaceAll(':', '').substring(0, 14)}.${object.millisecond.toString().padLeft(3, '0')}";
  }
}
