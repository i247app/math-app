import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/settings/widgets/profile_list/parent_code_action_button.dart';

class ParentProfileCodeLine extends StatelessWidget {
  const ParentProfileCodeLine({
    super.key,
    required this.profile,
    required this.isActive,
    required this.scale,
  });

  final StudentProfile profile;
  final bool isActive;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final profileCode = profile.profileCode?.trim();
    if (profileCode == null || profileCode.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            '${context.getText(AppKeys.profileCodeLabel)}: $profileCode',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color:
                  isActive ? const Color(0xFF604950) : const Color(0xFF6B7280),
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        ParentCodeActionButton(
          profileCode: profileCode,
          scale: scale,
        ),
      ],
    );
  }
}
