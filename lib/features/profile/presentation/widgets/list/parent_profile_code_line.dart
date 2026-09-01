import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/presentation/widgets/list/parent_code_action_button.dart';

class ParentProfileCodeLine extends StatelessWidget {
  const ParentProfileCodeLine({
    super.key,
    required this.profile,
    required this.isActive,
  });

  final StudentProfile profile;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final profileCode = profile.profileCode?.trim();
    if (profileCode == null || profileCode.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      spacing: 8,
      children: [
        Flexible(
          child: Text(
            '${context.getText(AppKeys.profileCodeLabel)}: $profileCode',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: isActive
                  ? const Color(0xFF604950)
                  : const Color(0xFF6B7280),
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        ParentCodeActionButton(profileCode: profileCode),
      ],
    );
  }
}
