import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

    test(
      'filled primary actions retain readable paired labels in both themes',
      () {
        for (final colors in [AppThemeColors.light, AppThemeColors.dark]) {
          final background = colors.primaryAction.computeLuminance();
          final foreground = colors.onPrimaryAction.computeLuminance();
          final lighter = background > foreground ? background : foreground;
          final darker = background > foreground ? foreground : background;
          expect((lighter + 0.05) / (darker + 0.05), greaterThanOrEqualTo(4.5));
        }
      },
    );

    test('action pairs support theme overrides and interpolation', () {
      final changed = AppThemeColors.light.copyWith(
        primaryAction: Colors.blue,
        onPrimaryAction: Colors.yellow,
      );
      expect(changed.primaryAction, Colors.blue);
      expect(changed.onPrimaryAction, Colors.yellow);
      final middle = AppThemeColors.light.lerp(AppThemeColors.dark, 0.5);
      expect(
        middle.primaryAction,
        Color.lerp(
          AppThemeColors.light.primaryAction,
          AppThemeColors.dark.primaryAction,
          0.5,
        ),
      );
      expect(
        middle.onPrimaryAction,
        Color.lerp(
          AppThemeColors.light.onPrimaryAction,
          AppThemeColors.dark.onPrimaryAction,
          0.5,
        ),
      );
    });

    test('installs matching semantic tokens in each application theme', () {
      final light = AppTheme.light().extension<AppThemeColors>();
      final dark = AppTheme.dark().extension<AppThemeColors>();

      expect(light, AppThemeColors.light);
      expect(dark, AppThemeColors.dark);
      expect(AppTheme.light().brightness, Brightness.light);
      expect(AppTheme.dark().brightness, Brightness.dark);
    });

    test('installs the centralized typography scale in both themes', () {
      final light = AppTheme.light().textTheme;
      final dark = AppTheme.dark().textTheme;

      expect(
        light.bodyLarge?.fontFamily,
        AppTypography.light().bodyLarge?.fontFamily,
      );
      expect(
        dark.bodyLarge?.fontFamily,
        AppTypography.dark().bodyLarge?.fontFamily,
      );
      expect(light.bodyLarge?.fontFamily, isNotNull);
      expect(dark.bodyLarge?.fontFamily, isNotNull);
    });
  });
}
