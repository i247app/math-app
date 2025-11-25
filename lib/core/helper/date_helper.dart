import 'package:intl/intl.dart';

/// DateHelper contains helper methods to convert between DateTime and String
abstract class DateHelper {
  static const String prettyDateFormat = 'dd-MMM-yyyy';
  static const String prettyTimestampFormat = 'MMM d, yyyy \'at\' h:mm a';
  static const String prettyTimeFormat = 'h:mm a';

  // expecting a utc DateTime String from server
  static DateTime? from20FSP(String z) {
    // const isUTC = true;
    try {
      // yyyyMMddHHmmss.SSSSSS
      String year = z.substring(0, 4);
      String month = z.substring(4, 6);
      String date = z.substring(6, 8);
      String hour = z.substring(8, 10);
      String min = z.substring(10, 12);
      String sec = z.substring(12, 14);
      return DateTime.utc(
        int.parse(year), // YEAR
        int.parse(month), // MONTH
        int.parse(date), // DATE
        int.parse(hour), // HOUR
        int.parse(min), // MINUTE
        int.parse(sec), // SECOND
      );
    } catch (e) {
      return null;
    }
  }

  static String? to20FSP(DateTime date) {
    try {
      // if (toUTC) {
      //   date = date.toUtc();
      // }
      final convertD = date.toString();
      final year = convertD.substring(0, 4);
      final month = convertD.substring(5, 7);
      final monthDate = convertD.substring(8, 10);
      final hour = convertD.substring(11, 13);
      final min = convertD.substring(14, 16);
      final sec = convertD.substring(17, 19);
      final meSec = convertD.substring(20);
      // String vToString =
      //     year + month + monthDate + hour + min + sec + "." + meSec;
      String vToString = "$year$month$monthDate$hour$min$sec.$meSec";
      vToString = vToString.replaceAll(RegExp(r"[a-zA-Z]"), "");
      // print("vToString : $vToString");
      return vToString;
    } catch (e) {
      // print(e.toString());
      return null;
    }
  }

  static String prettyDate(DateTime d) {
    return DateFormat(prettyDateFormat).format(d);
  }

  static String prettyTimestamp(DateTime d) {
    return DateFormat(prettyTimestampFormat).format(d);
  }

  static String prettyTime(DateTime d) {
    return DateFormat(prettyTimeFormat).format(d);
  }

  static String prettyTimeLocal(DateTime d) {
    return DateFormat(prettyTimeFormat).format(d.toLocal());
  }

  static String? prettyDateNull(DateTime? d) {
    return d == null ? null : prettyDate(d);
  }
}
