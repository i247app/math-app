part of '../../../home_screen.dart';

({Color color, String label}) _parentAssessmentScoreStyle(
  BuildContext context,
  int? percentage,
) {
  if (percentage == null) {
    return (
      color: const Color(0xFFDE8C4B),
      label: context.getText(AppKeys.incomplete),
    );
  }
  final score = (percentage / 10).round();
  if (score >= 9) {
    return (
      color: const Color(0xFF0A8A4D),
      label: context.getText(AppKeys.excellent),
    );
  }
  if (score >= 7) {
    return (
      color: const Color(0xFFF4B62D),
      label: context.getText(AppKeys.good),
    );
  }
  if (score >= 5) {
    return (
      color: const Color.fromARGB(255, 244, 135, 45),
      label: context.getText(AppKeys.niceTry),
    );
  }
  return (
    color: const Color(0xFFD71920),
    label: context.getText(AppKeys.failed),
  );
}

({String dt, String tm}) _parentAssessmentDateParts(String? isoDate) {
  final parsed = DateTime.tryParse(isoDate ?? '')?.toLocal();
  if (parsed == null) {
    return (dt: '--/--/----', tm: '--:--');
  }
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return (
    dt: '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}',
    tm: '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)}',
  );
}
