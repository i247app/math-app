part of '../../history_tab.dart';

_ScoreBadgeColors _scoreColors(BuildContext context, int? percent) {
  if (percent == null) {
    return _ScoreBadgeColors(
      foreground: const Color(0xFF0A8A4D),
      label: context.getText(AppKeys.excellent),
    );
  }

  final scoreOutOf10 = (percent / 10).round();

  if (scoreOutOf10 >= 9) {
    return _ScoreBadgeColors(
      foreground: const Color(0xFF0A8A4D), // Green
      label: context.getText(AppKeys.excellent),
    );
  }
  if (scoreOutOf10 >= 7) {
    return _ScoreBadgeColors(
      foreground: const Color(0xFFF4B62D),
      label: context.getText(AppKeys.good),
    );
  }
  if (scoreOutOf10 >= 5) {
    return _ScoreBadgeColors(
      foreground: const Color.fromARGB(255, 244, 135, 45),
      label: context.getText(AppKeys.niceTry),
    );
  }
  return _ScoreBadgeColors(
    foreground: const Color(0xFFD71920),
    label: context.getText(AppKeys.failed),
  );
}
