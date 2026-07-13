import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/settings/application/settings_constants.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/settings/widgets/language/language_header.dart';
import 'package:numi/features/settings/widgets/language/language_option_card.dart';
import 'package:numi/shared/widgets/loading_screen.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  bool _isChangingLanguage = false;
  bool _showChangingLanguageOverlay = false;

  Future<void> _changeLanguage(AppLanguage language) async {
    HapticFeedback.selectionClick();
    final lingo = LingoScope.read(context);
    if (lingo.language == language) {
      return;
    }

    setState(() => _isChangingLanguage = true);
    try {
      await _runWithDeferredOverlay(() => lingo.setLanguage(language));
      if (mounted) {
        setState(() {
          _isChangingLanguage = false;
          _showChangingLanguageOverlay = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isChangingLanguage = false;
          _showChangingLanguageOverlay = false;
        });
      }
    }
  }

  Future<void> _runWithDeferredOverlay(Future<void> Function() action) async {
    var completed = false;
    Future<void>.delayed(settingsLoadingDelay, () {
      if (completed || !mounted) {
        return;
      }
      setState(() => _showChangingLanguageOverlay = true);
    });

    try {
      await action();
    } finally {
      completed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LingoScope.of(context).language;
    final media = MediaQuery.of(context);
    final width = math.min(media.size.width, 430.0);
    final scale = math.min(
      width / _designWidth,
      media.size.height / _designHeight,
    );

    final colors = context.themeColors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: !_isChangingLanguage,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: colors.pageBackground,
              body: SafeArea(
                child: Center(
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LanguageHeader(scale: scale),
                        SizedBox(height: 62 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                          child: Column(
                            children: [
                              LanguageOptionCard(
                                flag: '🇻🇳',
                                title: context.getText(
                                  AppKeys.languageVietnamese,
                                ),
                                selected: currentLanguage == AppLanguage.vi,
                                scale: scale,
                                onTap: () => _changeLanguage(AppLanguage.vi),
                              ),
                              SizedBox(height: 18 * scale),
                              LanguageOptionCard(
                                flag: '🇺🇸',
                                title: context.getText(AppKeys.languageEnglish),
                                selected: currentLanguage == AppLanguage.en,
                                scale: scale,
                                onTap: () => _changeLanguage(AppLanguage.en),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_showChangingLanguageOverlay)
              Positioned.fill(
                child: LoadingScreen(
                  message: context.getText(AppKeys.switchingLanguage),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
