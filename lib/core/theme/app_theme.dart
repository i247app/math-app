import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_theme_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final textTheme = AppTypography.light();
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.teal700,
          onPrimary: Colors.white,
          secondary: AppColors.coral600,
          onSecondary: Colors.white,
          tertiary: AppColors.navy,
          surface: Colors.white,
          onSurface: AppColors.textPrimary,
          error: AppColors.red,
          onError: Colors.white,
          outline: AppColors.borderSoft,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.appBackground,
      textTheme: textTheme,
      extensions: const [AppThemeColors.light],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.tealIcon,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.tealIcon,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borderNeutral),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFBFC9CA),
          disabledForegroundColor: Colors.white,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal700,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppThemeColors.light.inputSurface,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppThemeColors.light.inputHint,
          letterSpacing: 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r18),
          borderSide: const BorderSide(color: AppColors.borderNeutral),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r18),
          borderSide: const BorderSide(color: AppColors.borderNeutral),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r18),
          borderSide: const BorderSide(color: AppColors.tealIcon, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final textTheme = AppTypography.dark();
    const colorScheme = ColorScheme.dark(
      primary: AppColors.darkPrimaryTeal,
      onPrimary: AppColors.darkOnPrimary,
      secondary: AppColors.darkActionOrange,
      onSecondary: AppColors.darkOnPrimary,
      tertiary: AppColors.darkSecondaryBlue,
      onTertiary: AppColors.darkOnPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      error: AppColors.redSoft,
      onError: AppColors.darkBackground,
      outline: AppColors.darkOutline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      canvasColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      extensions: const [AppThemeColors.dark],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkOnSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurfaceHigh,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurfaceHigh,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurfaceHigh,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkOutline),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkPrimaryTeal,
          foregroundColor: AppColors.darkOnPrimary,
          disabledBackgroundColor: AppColors.darkSurfaceHigh,
          disabledForegroundColor: AppColors.darkOnSurfaceMuted,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimaryTeal,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppThemeColors.dark.inputSurface,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppThemeColors.dark.inputHint,
          letterSpacing: 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r18),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r18),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r18),
          borderSide: const BorderSide(
            color: AppColors.darkPrimaryTeal,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
