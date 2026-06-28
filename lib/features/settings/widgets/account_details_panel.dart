import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/settings/widgets/account/account_avatar.dart';
import 'package:numi_flutter/features/settings/widgets/account/account_edit_button.dart';
import 'package:numi_flutter/features/settings/widgets/account/account_phone_field.dart';
import 'package:numi_flutter/features/settings/widgets/account/account_text_field.dart';
import 'package:numi_flutter/features/settings/widgets/account/settings_cancel_button.dart';
import 'package:numi_flutter/features/settings/widgets/account/settings_save_button.dart';

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
    required this.scale,
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
  final double scale;

  @override
  Widget build(BuildContext context) {
    final fieldGap = 20 * scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isEditing) ...[
          Align(
            alignment: Alignment.centerRight,
            child: AccountEditButton(
              enabled: true,
              scale: scale,
              onTap: onEdit,
            ),
          ),
          SizedBox(height: 10 * scale),
        ],
        AccountAvatar(
          avatarUrl: avatarUrl,
          avatarPath: avatarPath,
          isEditing: isEditing,
          isPickingAvatar: isPickingAvatar,
          scale: scale,
          onCameraTap: onAvatarTap,
        ),
        SizedBox(height: 4 * scale),
        AccountTextField(
          label: context.getText(AppKeys.username),
          controller: usernameController,
          isEditing: isEditing,
          trailing: Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF087A40),
            size: 19 * scale,
          ),
          scale: scale,
        ),
        SizedBox(height: fieldGap),
        AccountPhoneField(
          label: context.getText(AppKeys.phoneNumber),
          controller: phoneController,
          isEditing: isEditing,
          scale: scale,
        ),
        SizedBox(height: fieldGap),
        AccountTextField(
          label: context.getText(AppKeys.email),
          controller: emailController,
          isEditing: isEditing,
          keyboardType: TextInputType.emailAddress,
          scale: scale,
        ),
        if (isEditing) ...[
          SizedBox(height: 22 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SettingsCancelButton(
                scale: scale,
                onTap: isSaving ? () {} : onCancel,
              ),
              SizedBox(width: 14 * scale),
              Opacity(
                opacity: isSaving ? 0.72 : 1,
                child: SettingsSaveButton(
                  scale: scale,
                  onTap: isSaving ? () {} : onSave,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
