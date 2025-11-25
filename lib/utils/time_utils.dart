import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TimeUtils {
  TimeUtils._();

  static String formatToUtc(DateTime dateTime) {
    final utcDateTime = dateTime.toUtc();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(utcDateTime);
  }

  /// Parses a custom UTC timestamp string "yyyyMMddHHmmss.SSSSSS" into a UTC DateTime object.
  static DateTime? parseCustomTimestamp(String timestamp) {
    if (timestamp.length != 21) {
      debugPrint(
        "TimeUtils Error: Invalid timestamp format. Expected length 21, got ${timestamp.length}.",
      );
      return null;
    }
    try {
      final year = int.parse(timestamp.substring(0, 4));
      final month = int.parse(timestamp.substring(4, 6));
      final day = int.parse(timestamp.substring(6, 8));
      final hour = int.parse(timestamp.substring(8, 10));
      final minute = int.parse(timestamp.substring(10, 12));
      final second = int.parse(timestamp.substring(12, 14));
      final microsecond = int.parse(timestamp.substring(15, 21));

      return DateTime.utc(year, month, day, hour, minute, second, 0, microsecond);
    } catch (e) {
      debugPrint("TimeUtils Error: Failed to parse timestamp '$timestamp'. Exception: $e");
      return null;
    }
  }

  /// Parses the server's UTC timestamp string and converts it to a local DateTime object.
  static DateTime? parseServerUtcToLocal(String timestamp) {
    final utcTime = parseCustomTimestamp(timestamp);
    return utcTime?.toLocal();
  }

  /// Converts a local DateTime object to a UTC timestamp string in "yyyyMMddHHmmss.SSSSSS" format.
  static String formatLocalTimeToServerUtcString(DateTime localTime) {
    final utcTime = localTime.toUtc();
    final year = utcTime.year.toString().padLeft(4, '0');
    final month = utcTime.month.toString().padLeft(2, '0');
    final day = utcTime.day.toString().padLeft(2, '0');
    final hour = utcTime.hour.toString().padLeft(2, '0');
    final minute = utcTime.minute.toString().padLeft(2, '0');
    final second = utcTime.second.toString().padLeft(2, '0');
    final microsecond = (utcTime.millisecond * 1000 + utcTime.microsecond).toString().padLeft(
      6,
      '0',
    );

    return '$year$month$day$hour$minute$second.$microsecond';
  }

  static Duration? getDurationBetween(String timestampString, DateTime compareTo) {
    final DateTime? parsedUtcTime = parseCustomTimestamp(timestampString);

    if (parsedUtcTime == null) {
      return null;
    }

    final DateTime referenceUtcTime = compareTo.toUtc();

    return referenceUtcTime.difference(parsedUtcTime);
  }

  static Duration? getUtcDurationFromNow(String serverTimestampString) {
    final DateTime? serverUtcTime = parseCustomTimestamp(serverTimestampString);
    if (serverUtcTime == null) {
      return null;
    }
    final DateTime currentUtcTime = DateTime.now().toUtc();
    return serverUtcTime.difference(currentUtcTime);
  }

  static String formatDateTime(DateTime dateTime, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(format).format(dateTime);
  }

  static String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.isNegative) {
      return formatDateTime(dateTime, format: 'dd MMM, yyyy');
    }

    if (difference.inSeconds < 5) {
      return "just now";
    }
    if (difference.inMinutes < 1) {
      return "${difference.inSeconds} seconds ago";
    }
    if (difference.inHours < 1) {
      return "${difference.inMinutes} minutes ago";
    }
    if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    }
    if (difference.inDays == 1) {
      return "yesterday";
    }
    if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    }
    if (difference.inDays < 31) {
      final weeks = (difference.inDays / 7).floor();
      return "$weeks weeks ago";
    }
    return formatDateTime(dateTime, format: 'dd MMM, yyyy');
  }

  static bool isExpired(
    DateTime timestamp, {
    Duration expiryDuration = const Duration(seconds: 60),
  }) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.isNegative) {
      return false;
    }

    return difference > expiryDuration;
  }

  static bool isTimestampStringExpired(String timestampString, {int expirySeconds = 60}) {
    final DateTime? parsedTime = parseCustomTimestamp(timestampString);
    if (parsedTime == null) {
      return false;
    }
    return isExpired(parsedTime, expiryDuration: Duration(seconds: expirySeconds));
  }
}
