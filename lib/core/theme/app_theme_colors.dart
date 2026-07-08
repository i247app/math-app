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
    required this.accent,
    required this.accentStrong,
    required this.error,
    required this.border,
    required this.borderStrong,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.inputSurface,
    required this.inputHint,
    required this.shadow,
    required this.authBackSurface,
    required this.authBackBorder,
    required this.otpBorder,
    required this.passcodeBorder,
    required this.passcodeShadow,
    required this.welcomeTitle,
    required this.welcomeInactiveDot,
    required this.authBackgroundStart,
    required this.authBackgroundEnd,
    required this.authDecorRing,
    required this.authDecorCircle,
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
  final Color accent;
  final Color accentStrong;
  final Color error;
  final Color border;
  final Color borderStrong;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color inputSurface;
  final Color inputHint;
  final Color shadow;
  final Color authBackSurface;
  final Color authBackBorder;
  final Color otpBorder;
  final Color passcodeBorder;
  final Color passcodeShadow;
  final Color welcomeTitle;
  final Color welcomeInactiveDot;
  final Color authBackgroundStart;
  final Color authBackgroundEnd;
  final Color authDecorRing;
  final Color authDecorCircle;

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
    accent: AppColors.coral600,
    accentStrong: AppColors.coral500,
    error: Color(0xFFD9534F),
    border: AppColors.borderNeutral,
    borderStrong: Color(0xFFB5BFC2),
    disabledBackground: Color(0xFFB5BFC2),
    disabledForeground: Colors.white,
    inputSurface: Colors.white,
    inputHint: Color(0xFFB9C2C5),
    shadow: Color(0x14000000),
    authBackSurface: Color(0xCCFFFFFF),
    authBackBorder: Color(0x1AA2B1A3),
    otpBorder: Color(0xFFF47B55),
    passcodeBorder: Color(0xFF6E7474),
    passcodeShadow: Color(0xFFDCBFC8),
    welcomeTitle: AppColors.welcomeTitle,
    welcomeInactiveDot: AppColors.inactiveDot,
    authBackgroundStart: AppColors.aquaMist,
    authBackgroundEnd: AppColors.mintMist,
    authDecorRing: AppColors.sandRing,
    authDecorCircle: Color(0x5C79D5CF),
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
    accent: AppColors.darkActionOrange,
    accentStrong: AppColors.darkActionOrange,
    error: Color(0xFFFF8A8A),
    border: AppColors.darkOutline,
    borderStrong: Color(0xFF547070),
    disabledBackground: AppColors.darkSurfaceHigh,
    disabledForeground: AppColors.darkOnSurfaceMuted,
    inputSurface: AppColors.darkSurface,
    inputHint: AppColors.darkOnSurfaceMuted,
    shadow: Color(0x52000000),
    authBackSurface: Color(0xE6243333),
    authBackBorder: Color(0x80355151),
    otpBorder: AppColors.darkActionOrange,
    passcodeBorder: Color(0xFF6A8581),
    passcodeShadow: Color(0xFF0C1515),
    welcomeTitle: AppColors.darkOnSurface,
    welcomeInactiveDot: AppColors.darkOutline,
    authBackgroundStart: AppColors.darkBackground,
    authBackgroundEnd: AppColors.darkSurface,
    authDecorRing: Color(0x66355151),
    authDecorCircle: Color(0x661F5A5A),
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
    Color? accent,
    Color? accentStrong,
    Color? error,
    Color? border,
    Color? borderStrong,
    Color? disabledBackground,
    Color? disabledForeground,
    Color? inputSurface,
    Color? inputHint,
    Color? shadow,
    Color? authBackSurface,
    Color? authBackBorder,
    Color? otpBorder,
    Color? passcodeBorder,
    Color? passcodeShadow,
    Color? welcomeTitle,
    Color? welcomeInactiveDot,
    Color? authBackgroundStart,
    Color? authBackgroundEnd,
    Color? authDecorRing,
    Color? authDecorCircle,
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
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      error: error ?? this.error,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledForeground: disabledForeground ?? this.disabledForeground,
      inputSurface: inputSurface ?? this.inputSurface,
      inputHint: inputHint ?? this.inputHint,
      shadow: shadow ?? this.shadow,
      authBackSurface: authBackSurface ?? this.authBackSurface,
      authBackBorder: authBackBorder ?? this.authBackBorder,
      otpBorder: otpBorder ?? this.otpBorder,
      passcodeBorder: passcodeBorder ?? this.passcodeBorder,
      passcodeShadow: passcodeShadow ?? this.passcodeShadow,
      welcomeTitle: welcomeTitle ?? this.welcomeTitle,
      welcomeInactiveDot: welcomeInactiveDot ?? this.welcomeInactiveDot,
      authBackgroundStart: authBackgroundStart ?? this.authBackgroundStart,
      authBackgroundEnd: authBackgroundEnd ?? this.authBackgroundEnd,
      authDecorRing: authDecorRing ?? this.authDecorRing,
      authDecorCircle: authDecorCircle ?? this.authDecorCircle,
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
      accent: Color.lerp(accent, other.accent, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      error: Color.lerp(error, other.error, t)!,
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
      authBackSurface: Color.lerp(authBackSurface, other.authBackSurface, t)!,
      authBackBorder: Color.lerp(authBackBorder, other.authBackBorder, t)!,
      otpBorder: Color.lerp(otpBorder, other.otpBorder, t)!,
      passcodeBorder: Color.lerp(passcodeBorder, other.passcodeBorder, t)!,
      passcodeShadow: Color.lerp(passcodeShadow, other.passcodeShadow, t)!,
      welcomeTitle: Color.lerp(welcomeTitle, other.welcomeTitle, t)!,
      welcomeInactiveDot: Color.lerp(
        welcomeInactiveDot,
        other.welcomeInactiveDot,
        t,
      )!,
      authBackgroundStart: Color.lerp(
        authBackgroundStart,
        other.authBackgroundStart,
        t,
      )!,
      authBackgroundEnd: Color.lerp(
        authBackgroundEnd,
        other.authBackgroundEnd,
        t,
      )!,
      authDecorRing: Color.lerp(authDecorRing, other.authDecorRing, t)!,
      authDecorCircle: Color.lerp(authDecorCircle, other.authDecorCircle, t)!,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get themeColors {
    return Theme.of(this).extension<AppThemeColors>()!;
  }
}
