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
    return _andikaTextTheme(ThemeData.light().textTheme);
  }

  static TextTheme dark() {
    return _andikaTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: AppColors.darkOnSurface,
      displayColor: AppColors.darkOnSurface,
    );
  }

  // Google Fonts 9's TextTheme helper uses material_ui's separate theme type.
  // Apply font styles to Flutter's TextTheme while retaining its type scale.
  static TextTheme _andikaTextTheme(TextTheme theme) => TextTheme(
    displayLarge: GoogleFonts.andika(textStyle: theme.displayLarge),
    displayMedium: GoogleFonts.andika(textStyle: theme.displayMedium),
    displaySmall: GoogleFonts.andika(textStyle: theme.displaySmall),
    headlineLarge: GoogleFonts.andika(textStyle: theme.headlineLarge),
    headlineMedium: GoogleFonts.andika(textStyle: theme.headlineMedium),
    headlineSmall: GoogleFonts.andika(textStyle: theme.headlineSmall),
    titleLarge: GoogleFonts.andika(textStyle: theme.titleLarge),
    titleMedium: GoogleFonts.andika(textStyle: theme.titleMedium),
    titleSmall: GoogleFonts.andika(textStyle: theme.titleSmall),
    bodyLarge: GoogleFonts.andika(textStyle: theme.bodyLarge),
    bodyMedium: GoogleFonts.andika(textStyle: theme.bodyMedium),
    bodySmall: GoogleFonts.andika(textStyle: theme.bodySmall),
    labelLarge: GoogleFonts.andika(textStyle: theme.labelLarge),
    labelMedium: GoogleFonts.andika(textStyle: theme.labelMedium),
    labelSmall: GoogleFonts.andika(textStyle: theme.labelSmall),
  );
}

extension AppTypographyContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}
