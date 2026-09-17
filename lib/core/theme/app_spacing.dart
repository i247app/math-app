/// Shared spacing scale used by layout and component padding.
///
/// Keep spacing independent from [ThemeData]: unlike colors and typography,
/// these values do not change between light and dark themes.
abstract final class AppSpacing {
  const AppSpacing._();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
}
