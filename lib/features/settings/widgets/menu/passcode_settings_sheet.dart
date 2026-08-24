import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_radius.dart';
import 'package:numi/core/theme/app_spacing.dart';
import 'package:numi/features/settings/widgets/menu/settings_action_card.dart';

enum PasscodeSettingsAction { change, remove }

class PasscodeSettingsSheet extends StatelessWidget {
  const PasscodeSettingsSheet({
    super.key,
    required this.onChange,
    required this.onRemove,
  });

  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.s16),
        padding: const EdgeInsets.all(AppSpacing.s18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.r24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s12,
          children: [
            SettingsActionCard(
              icon: Icons.edit_outlined,
              iconColor: const Color(0xFF327F84),
              iconBackground: const Color(0xFFE5F7F8),
              title: context.getText(AppKeys.passcodeChange),
              subtitle: context.getText(AppKeys.passcodeMenuSubtitleManage),
              onTap: onChange,
            ),
            SettingsActionCard(
              icon: Icons.lock_open_rounded,
              iconColor: AppColors.orange500,
              iconBackground: const Color(0xFFFFEAEA),
              title: context.getText(AppKeys.passcodeRemove),
              subtitle: context.getText(AppKeys.passcodeRemove),
              isDestructive: true,
              onTap: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
