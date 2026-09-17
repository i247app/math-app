import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/theme/app_colors.dart';

class TeacherClassDetailFunctionTile extends StatelessWidget {
  const TeacherClassDetailFunctionTile({
    super.key,
    this.iconAsset,
    this.label,
    this.onTap,
  });
  final String? iconAsset;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: const Color(0xFFDDE4E6), width: 2),
          ),
          child: iconAsset == null
              ? const SizedBox.shrink()
              : Column(
                  spacing: 1,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(iconAsset!, width: 44, height: 44),
                    Text(
                      label ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textInkDark,
                        fontSize: FontSize.small,
                        fontWeight: FontWeight.w700,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
