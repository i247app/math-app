import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Central source for the app font family and Material typography scale.
///
/// Feature and shared widgets should consume [TextTheme] from the current
/// [ThemeData] instead of constructing font styles directly. This keeps font
/// loading, light/dark defaults, and future type-scale changes in one place.
abstract final class AppTypography {
  const AppTypography._();

  static TextTheme light() {
    return GoogleFonts.andikaTextTheme(ThemeData.light().textTheme);
  }

  static TextTheme dark() {
    return GoogleFonts.andikaTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: AppColors.darkOnSurface,
      displayColor: AppColors.darkOnSurface,
    );
  }
}

extension AppTypographyContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}
