import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/core/theme/app_spacing.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_theme_scope.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/settings/application/settings_constants.dart';
import 'package:numi/shared/widgets/settings_action_card.dart';
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4),
            child: Column(
              children: [
                SettingsAvatar(
                  activeProfile: activeProfile,
                  fallbackAvatarUrl: fallbackAvatarUrl,
                  fallbackAvatarPath: fallbackAvatarPath,
                  onSwitchTap: onProfileTap,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    _displayName(context),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: colors.textPrimary,
                      fontSize: FontSize.xxxl,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s32),
                  child: Column(
                    spacing: AppSpacing.s12,
                    children: [
                      _animatedAction(
                        child: SettingsActionCard(
                          icon: Icons.account_circle_outlined,
                          iconColor: const Color(0xFFC21873),
                          iconBackground: const Color(0xFFFFF0F7),
                          title: context.getText(AppKeys.accountMenuTitle),
                          subtitle: context.getText(
                            AppKeys.accountMenuSubtitle,
                          ),
                          onTap: onAccountTap,
                        ),
                      ),
                      _animatedAction(
                        child: SettingsActionCard(
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF008A52),
                          iconBackground: const Color(0xFFD6FFE3),
                          title: context.getText(AppKeys.profileMenuTitle),
                          subtitle: context.getText(
                            AppKeys.profileMenuSubtitle,
                          ),
                          onTap: onProfileTap,
                        ),
                      ),
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
                          onTap: onPasscodeTap,
                        ),
                      ),
                      _animatedAction(
                        child: SettingsLanguageCard(
                          currentLanguage: currentLanguage,
                          onLanguageChanged: onLanguageChanged,
                        ),
                      ),
                      _animatedAction(
                        child: SettingsThemeSwitchCard(
                          controller: themeController,
                        ),
                      ),
                      _animatedAction(
                        child: SettingsActionCard(
                          icon: Icons.logout_rounded,
                          iconColor: colors.accentStrong,
                          iconBackground: const Color(0xFFFFEAEA),
                          title: context.getText(AppKeys.logout),
                          subtitle: context.getText(AppKeys.logoutSubtitle),
                          isDestructive: true,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onLogoutTap();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  String _displayName(BuildContext context) {
    final name = activeProfile?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final accountName = username.trim();
    return accountName.isEmpty
        ? context.getText(AppKeys.accountNotUpdated)
        : accountName;
  }
}
