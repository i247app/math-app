import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_skeleton_block.dart';

class HistorySkeletonCard extends StatelessWidget {
  const HistorySkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 116,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border, width: 1.3),
      ),
      child: const Row(
        spacing: 14,
        children: [
          HistorySkeletonBlock(width: 54, height: 54, radius: 27),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    HistorySkeletonBlock(width: 82, height: 12, radius: 6),
                    HistorySkeletonBlock(width: 54, height: 12, radius: 6),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: HistorySkeletonBlock(
                    width: 150,
                    height: 17,
                    radius: 8,
                  ),
                ),
                HistorySkeletonBlock(width: 110, height: 11, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
