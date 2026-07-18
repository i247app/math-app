import 'package:flutter/material.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';

class HistoryMetaItem extends StatelessWidget {
  const HistoryMetaItem({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Icon(icon, color: AppColors.textWarmMuted, size: 18),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textWarmMuted,
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
