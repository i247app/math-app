/// Shared corner-radius scale for surfaces and interactive components.
///
/// Radius values are static design tokens because they are not theme-mode
/// dependent. Theme-aware values such as colors must still come from the
/// current [BuildContext].
abstract final class AppRadius {
  const AppRadius._();

  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r18 = 18;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double r28 = 28;
  static const double r32 = 32;

  /// A visually circular end-cap for chips, pills, and capsule buttons.
  static const double full = 999;
}
