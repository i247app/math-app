import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class SettingHeader extends StatelessWidget {
  const SettingHeader({
    super.key,
    required this.title,
    required this.canGoBack,
    required this.onBack,
    required this.backgroundColor,
    required this.scale,
    required this.topInset,
  });

  final String title;
  final bool canGoBack;
  final VoidCallback onBack;
  final Color backgroundColor;
  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      height: topInset + 60 * scale,
      decoration: BoxDecoration(color: backgroundColor),
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        topInset + 6 * scale,
        18 * scale,
        6 * scale,
      ),
      child: Row(
        children: [
          if (canGoBack)
            _SettingHeaderButton(
              icon: Icons.arrow_back_rounded,
              outlined: false,
              onTap: onBack,
              scale: scale,
            )
          else
            SizedBox(width: 40 * scale),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: colors.brandStrong,
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          SizedBox(width: 40 * scale),
        ],
      ),
    );
  }
}

class _SettingHeaderButton extends StatelessWidget {
  const _SettingHeaderButton({
    required this.icon,
    required this.outlined,
    required this.onTap,
    required this.scale,
  });

  final IconData icon;
  final bool outlined;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
      },
      child: SizedBox(
        width: 40 * scale,
        height: 40 * scale,
        child: Icon(icon, color: colors.brandStrong, size: 22 * scale),
      ),
    );
  }
}
