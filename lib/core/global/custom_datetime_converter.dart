import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../utils/time_utils.dart';

class CustomDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const CustomDateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }
    final parsedDate = TimeUtils.parseCustomTimestamp(json);
    if (parsedDate == null) {
      debugPrint("CustomDateTimeConverter: Could not parse timestamp '$json'. Invalid format.");
    }
    return parsedDate;
  }

  @override
  String? toJson(DateTime? object) {
    if (object == null) {
      return null;
    }
    return TimeUtils.formatLocalTimeToServerUtcString(object);
  }
}
