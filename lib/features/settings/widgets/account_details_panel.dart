import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/settings/widgets/account/account_avatar.dart';
import 'package:numi/features/settings/widgets/account/account_edit_button.dart';
import 'package:numi/features/settings/widgets/account/account_phone_field.dart';
import 'package:numi/features/settings/widgets/account/account_text_field.dart';
import 'package:numi/features/settings/widgets/account/settings_cancel_button.dart';
import 'package:numi/features/settings/widgets/account/settings_save_button.dart';

class AccountDetailsPanel extends StatelessWidget {
  const AccountDetailsPanel({
    super.key,
    required this.avatarUrl,
    required this.avatarPath,
    required this.usernameController,
    required this.phoneController,
    required this.emailController,
    required this.isEditing,
    required this.isSaving,
    required this.isPickingAvatar,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.onAvatarTap,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool isEditing;
  final bool isSaving;
  final bool isPickingAvatar;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isEditing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AccountEditButton(enabled: true, onTap: onEdit),
                  ),
                ),
              AccountAvatar(
                avatarUrl: avatarUrl,
                avatarPath: avatarPath,
                isEditing: isEditing,
                isPickingAvatar: isPickingAvatar,
                onCameraTap: onAvatarTap,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AccountTextField(
                  label: context.getText(AppKeys.username),
                  controller: usernameController,
                  isEditing: isEditing,
                  hintText: context.getText(AppKeys.accountNotUpdated),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF087A40),
                    size: 19,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AccountPhoneField(
                  label: context.getText(AppKeys.phoneNumber),
                  controller: phoneController,
                  isEditing: isEditing,
                  hintText: context.getText(AppKeys.accountNotUpdated),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AccountTextField(
                  label: context.getText(AppKeys.email),
                  controller: emailController,
                  isEditing: isEditing,
                  keyboardType: TextInputType.emailAddress,
                  hintText: context.getText(AppKeys.accountNotUpdated),
                ),
              ),
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 14,
                    children: [
                      SettingsCancelButton(onTap: isSaving ? () {} : onCancel),
                      SettingsSaveButton(isLoading: isSaving, onTap: onSave),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
