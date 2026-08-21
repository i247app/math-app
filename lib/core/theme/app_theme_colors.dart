import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.pageBackground,
    required this.pageBackgroundTop,
    required this.surface,
    required this.elevatedSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.brand,
    required this.brandStrong,
    required this.onBrand,
    required this.accent,
    required this.accentStrong,
    required this.onAccent,
    required this.error,
    required this.onError,
    required this.errorSurface,
    required this.success,
    required this.onSuccess,
    required this.successSurface,
    required this.warning,
    required this.warningSurface,
    required this.info,
    required this.infoSurface,
    required this.border,
    required this.borderStrong,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.inputSurface,
    required this.inputHint,
    required this.shadow,
    required this.scrim,
    required this.skeleton,
    required this.otpBorder,
    required this.passcodeBorder,
    required this.passcodeShadow,
    required this.welcomeTitle,
    required this.welcomeInactiveDot,
  });

  final Color pageBackground;
  final Color pageBackgroundTop;
  final Color surface;
  final Color elevatedSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color brand;
  final Color brandStrong;
  final Color onBrand;
  final Color accent;
  final Color accentStrong;
  final Color onAccent;
  final Color error;
  final Color onError;
  final Color errorSurface;
  final Color success;
  final Color onSuccess;
  final Color successSurface;
  final Color warning;
  final Color warningSurface;
  final Color info;
  final Color infoSurface;
  final Color border;
  final Color borderStrong;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color inputSurface;
  final Color inputHint;
  final Color shadow;
  final Color scrim;
  final Color skeleton;
  final Color otpBorder;
  final Color passcodeBorder;
  final Color passcodeShadow;
  final Color welcomeTitle;
  final Color welcomeInactiveDot;

  static const light = AppThemeColors(
    pageBackground: AppColors.pageBackground,
    pageBackgroundTop: AppColors.pageBackgroundTop,
    surface: Colors.white,
    elevatedSurface: Colors.white,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textMuted,
    textMuted: AppColors.grayText,
    brand: AppColors.welcomeTeal,
    brandStrong: AppColors.tealIcon,
    onBrand: Colors.white,
    accent: AppColors.coral600,
    accentStrong: AppColors.coral500,
    onAccent: Colors.white,
    error: Color(0xFFD9534F),
    onError: Colors.white,
    errorSurface: Color(0xFFFFEDEC),
    success: AppColors.scoreGreen,
    onSuccess: Colors.white,
    successSurface: Color(0xFFE7F5ED),
    warning: AppColors.scoreYellow,
    warningSurface: Color(0xFFFFF4D8),
    info: AppColors.assessmentProgress,
    infoSurface: Color(0xFFE6F4FA),
    border: AppColors.borderNeutral,
    borderStrong: Color(0xFFB5BFC2),
    disabledBackground: Color(0xFFB5BFC2),
    disabledForeground: Colors.white,
    inputSurface: Colors.white,
    inputHint: Color(0xFFB9C2C5),
    shadow: Color(0x14000000),
    scrim: Color(0x66001741),
    skeleton: Color(0xFFE8EEF0),
    otpBorder: Color(0xFFF47B55),
    passcodeBorder: Color(0xFF6E7474),
    passcodeShadow: Color(0xFFDCBFC8),
    welcomeTitle: AppColors.welcomeTitle,
    welcomeInactiveDot: AppColors.inactiveDot,
  );

  static const dark = AppThemeColors(
    pageBackground: AppColors.darkBackground,
    pageBackgroundTop: AppColors.darkSurface,
    surface: AppColors.darkSurface,
    elevatedSurface: AppColors.darkSurfaceHigh,
    textPrimary: AppColors.darkOnSurface,
    textSecondary: AppColors.darkOnSurfaceMuted,
    textMuted: Color(0xFF88A19E),
    brand: AppColors.darkPrimaryTeal,
    brandStrong: Color(0xFF5EC7C2),
    onBrand: AppColors.darkOnPrimary,
    accent: AppColors.darkActionOrange,
    accentStrong: AppColors.darkActionOrange,
    onAccent: AppColors.darkBackground,
    error: Color(0xFFFF8A8A),
    onError: AppColors.darkBackground,
    errorSurface: Color(0xFF4A292B),
    success: Color(0xFF5DD6A0),
    onSuccess: AppColors.darkBackground,
    successSurface: Color(0xFF1E4435),
    warning: Color(0xFFFFD37A),
    warningSurface: Color(0xFF4B3B1D),
    info: Color(0xFF78C7FF),
    infoSurface: Color(0xFF1E3C50),
    border: AppColors.darkOutline,
    borderStrong: Color(0xFF547070),
    disabledBackground: AppColors.darkSurfaceHigh,
    disabledForeground: AppColors.darkOnSurfaceMuted,
    inputSurface: AppColors.darkSurface,
    inputHint: AppColors.darkOnSurfaceMuted,
    shadow: Color(0x52000000),
    scrim: Color(0xB8000000),
    skeleton: Color(0xFF2B4141),
    otpBorder: AppColors.darkActionOrange,
    passcodeBorder: Color(0xFF6A8581),
    passcodeShadow: Color(0xFF0C1515),
    welcomeTitle: AppColors.darkOnSurface,
    welcomeInactiveDot: AppColors.darkOutline,
  );

  @override
  AppThemeColors copyWith({
    Color? pageBackground,
    Color? pageBackgroundTop,
    Color? surface,
    Color? elevatedSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? brand,
    Color? brandStrong,
    Color? onBrand,
    Color? accent,
    Color? accentStrong,
    Color? onAccent,
    Color? error,
    Color? onError,
    Color? errorSurface,
    Color? success,
    Color? onSuccess,
    Color? successSurface,
    Color? warning,
    Color? warningSurface,
    Color? info,
    Color? infoSurface,
    Color? border,
    Color? borderStrong,
    Color? disabledBackground,
    Color? disabledForeground,
    Color? inputSurface,
    Color? inputHint,
    Color? shadow,
    Color? scrim,
    Color? skeleton,
    Color? otpBorder,
    Color? passcodeBorder,
    Color? passcodeShadow,
    Color? welcomeTitle,
    Color? welcomeInactiveDot,
  }) {
    return AppThemeColors(
      pageBackground: pageBackground ?? this.pageBackground,
      pageBackgroundTop: pageBackgroundTop ?? this.pageBackgroundTop,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      brand: brand ?? this.brand,
      brandStrong: brandStrong ?? this.brandStrong,
      onBrand: onBrand ?? this.onBrand,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      onAccent: onAccent ?? this.onAccent,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorSurface: errorSurface ?? this.errorSurface,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successSurface: successSurface ?? this.successSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      info: info ?? this.info,
      infoSurface: infoSurface ?? this.infoSurface,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledForeground: disabledForeground ?? this.disabledForeground,
      inputSurface: inputSurface ?? this.inputSurface,
      inputHint: inputHint ?? this.inputHint,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
      skeleton: skeleton ?? this.skeleton,
      otpBorder: otpBorder ?? this.otpBorder,
      passcodeBorder: passcodeBorder ?? this.passcodeBorder,
      passcodeShadow: passcodeShadow ?? this.passcodeShadow,
      welcomeTitle: welcomeTitle ?? this.welcomeTitle,
      welcomeInactiveDot: welcomeInactiveDot ?? this.welcomeInactiveDot,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      pageBackgroundTop: Color.lerp(
        pageBackgroundTop,
        other.pageBackgroundTop,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandStrong: Color.lerp(brandStrong, other.brandStrong, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      disabledBackground: Color.lerp(
        disabledBackground,
        other.disabledBackground,
        t,
      )!,
      disabledForeground: Color.lerp(
        disabledForeground,
        other.disabledForeground,
        t,
      )!,
      inputSurface: Color.lerp(inputSurface, other.inputSurface, t)!,
      inputHint: Color.lerp(inputHint, other.inputHint, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
      otpBorder: Color.lerp(otpBorder, other.otpBorder, t)!,
      passcodeBorder: Color.lerp(passcodeBorder, other.passcodeBorder, t)!,
      passcodeShadow: Color.lerp(passcodeShadow, other.passcodeShadow, t)!,
      welcomeTitle: Color.lerp(welcomeTitle, other.welcomeTitle, t)!,
      welcomeInactiveDot: Color.lerp(
        welcomeInactiveDot,
        other.welcomeInactiveDot,
        t,
      )!,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get themeColors {
    return Theme.of(this).extension<AppThemeColors>()!;
  }
}
