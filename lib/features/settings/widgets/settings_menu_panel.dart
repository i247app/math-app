import 'package:numi/features/settings/settings_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_theme_scope.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/settings/widgets/menu/settings_action_card.dart';
import 'package:numi/features/settings/widgets/menu/settings_avatar.dart';
import 'package:numi/features/settings/widgets/menu/settings_language_card.dart';
import 'package:numi/features/settings/widgets/menu/settings_theme_switch_card.dart';

class SettingsMenuPanel extends StatelessWidget {
  const SettingsMenuPanel({
    super.key,
    required this.activeProfile,
    required this.fallbackAvatarUrl,
    required this.fallbackAvatarPath,
    required this.username,
    required this.scale,
    required this.currentLanguage,
    required this.hasPasscode,
    required this.isLoadingPasscode,
    required this.animateActions,
    required this.onActionsAnimationEnd,
    required this.onAccountTap,
    required this.onProfileTap,
    required this.onPasscodeTap,
    required this.onLanguageChanged,
    required this.onLogoutTap,
  });

  final StudentProfile? activeProfile;
  final String? fallbackAvatarUrl;
  final String? fallbackAvatarPath;
  final String username;
  final double scale;
  final AppLanguage currentLanguage;
  final bool hasPasscode;
  final bool isLoadingPasscode;
  final bool animateActions;
  final VoidCallback onActionsAnimationEnd;
  final VoidCallback onAccountTap;
  final VoidCallback onProfileTap;
  final VoidCallback onPasscodeTap;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final themeController = AppThemeScope.of(context);

    return Column(
      children: [
        SizedBox(height: 4 * scale),
        SettingsAvatar(
          activeProfile: activeProfile,
          fallbackAvatarUrl: fallbackAvatarUrl,
          fallbackAvatarPath: fallbackAvatarPath,
          scale: scale,
          onSwitchTap: onProfileTap,
        ),
        SizedBox(height: 14 * scale),
        Text(
          _displayName(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: colors.textPrimary,
            fontSize: FontSize.xxxl * scale,
            fontWeight: FontWeight.w700,
            height: 1.05,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 32 * scale),
        _animatedAction(
          child: SettingsActionCard(
            icon: Icons.account_circle_outlined,
            iconColor: const Color(0xFFC21873),
            iconBackground: const Color(0xFFFFF0F7),
            title: context.getText(AppKeys.accountMenuTitle),
            subtitle: context.getText(AppKeys.accountMenuSubtitle),
            scale: scale,
            onTap: onAccountTap,
          ),
        ),
        SizedBox(height: 12 * scale),
        _animatedAction(
          child: SettingsActionCard(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF008A52),
            iconBackground: const Color(0xFFD6FFE3),
            title: context.getText(AppKeys.profileMenuTitle),
            subtitle: context.getText(AppKeys.profileMenuSubtitle),
            scale: scale,
            onTap: onProfileTap,
          ),
        ),
        SizedBox(height: 12 * scale),
        _animatedAction(
          child: SettingsActionCard(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFF327F84),
            iconBackground: const Color(0xFFE5F7F8),
            title: context.getText(AppKeys.passcodeMenuTitle),
            subtitle: context.getText(
              hasPasscode
                  ? AppKeys.passcodeMenuSubtitleManage
                  : AppKeys.passcodeMenuSubtitleSet,
            ),
            scale: scale,
            onTap: onPasscodeTap,
          ),
        ),
        SizedBox(height: 12 * scale),
        _animatedAction(
          child: SettingsLanguageCard(
            currentLanguage: currentLanguage,
            scale: scale,
            onLanguageChanged: onLanguageChanged,
          ),
        ),
        SizedBox(height: 12 * scale),
        _animatedAction(
          child: SettingsThemeSwitchCard(
            controller: themeController,
            scale: scale,
          ),
        ),
        SizedBox(height: 12 * scale),
        _animatedAction(
          child: SettingsActionCard(
            icon: Icons.logout_rounded,
            iconColor: colors.accentStrong,
            iconBackground: const Color(0xFFFFEAEA),
            title: context.getText(AppKeys.logout),
            subtitle: context.getText(AppKeys.logoutSubtitle),
            isDestructive: true,
            scale: scale,
            onTap: () {
              HapticFeedback.selectionClick();
              onLogoutTap();
            },
          ),
        ),
      ],
    );
  }

  Widget _animatedAction({required Widget child}) {
    if (!animateActions) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: settingsMenuFadeInDuration,
      curve: Curves.easeOutQuart,
      onEnd: onActionsAnimationEnd,
      builder: (context, value, animatedChild) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: Transform.scale(
            scale: 0.985 + 0.015 * value,
            alignment: Alignment.topCenter,
            child: animatedChild,
          ),
        ),
      ),
      child: child,
    );
  }

  String _displayName() {
    final name = activeProfile?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return username;
  }
}
