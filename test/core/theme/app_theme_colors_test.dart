import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

void main() {
  group('AppThemeColors', () {
    test('provides semantic state tokens for light and dark themes', () {
      for (final colors in [AppThemeColors.light, AppThemeColors.dark]) {
        expect(colors.success, isNot(colors.successSurface));
        expect(colors.warning, isNot(colors.warningSurface));
        expect(colors.info, isNot(colors.infoSurface));
        expect(colors.error, isNot(colors.errorSurface));
        expect(colors.scrim, isNot(colors.pageBackground));
        expect(colors.skeleton, isNot(colors.elevatedSurface));
      }
    });

    test('installs matching semantic tokens in each application theme', () {
      final light = AppTheme.light().extension<AppThemeColors>();
      final dark = AppTheme.dark().extension<AppThemeColors>();

      expect(light, AppThemeColors.light);
      expect(dark, AppThemeColors.dark);
      expect(AppTheme.light().brightness, Brightness.light);
      expect(AppTheme.dark().brightness, Brightness.dark);
    });
  });
}
