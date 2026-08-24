import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/core/theme/font_size.dart';

class ProfileIdLine extends StatelessWidget {
  const ProfileIdLine({
    super.key,
    required this.profile,
    required this.isActive,
  });

  final StudentProfile profile;
  final bool isActive;

  Future<void> _copyProfileCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileCode = profile.profileCode?.trim();
    if (profileCode == null || profileCode.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = isActive ? const Color(0xFF604950) : AppColors.textSubtle;

    return Row(
      spacing: 8,
      children: [
        Flexible(
          child: Text(
            '${context.getText(AppKeys.profileCodeLabel)}: $profileCode',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: color,
              fontSize: FontSize.small,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        Material(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => _copyProfileCode(context, profileCode),
            borderRadius: BorderRadius.circular(8),
            child: const SizedBox(
              height: 24,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 7,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF5E6A70),
                      size: 15,
                    ),
                    Icon(
                      Icons.qr_code_2_rounded,
                      color: Color(0xFF5E6A70),
                      size: 15,
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
