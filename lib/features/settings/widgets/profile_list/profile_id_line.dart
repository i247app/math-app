import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/settings/settings_style.dart';

class ProfileIdLine extends StatelessWidget {
  const ProfileIdLine({
    super.key,
    required this.profile,
    required this.isActive,
    required this.scale,
  });

  final StudentProfile profile;
  final bool isActive;
  final double scale;

  Future<void> _copyProfileCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.profileCodeCopied)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileCode = profile.profileCode?.trim();
    if (profileCode == null || profileCode.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = isActive ? const Color(0xFF604950) : settingsMuted;

    return Row(
      children: [
        Flexible(
          child: Text(
            '${context.getText(AppKeys.profileCodeLabel)}: $profileCode',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: color,
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        Material(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(8 * scale),
          child: InkWell(
            onTap: () => _copyProfileCode(context, profileCode),
            borderRadius: BorderRadius.circular(8 * scale),
            child: SizedBox(
              height: 24 * scale,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      color: const Color(0xFF5E6A70),
                      size: 15 * scale,
                    ),
                    SizedBox(width: 7 * scale),
                    Icon(
                      Icons.qr_code_2_rounded,
                      color: const Color(0xFF5E6A70),
                      size: 15 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
