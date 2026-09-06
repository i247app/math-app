import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class NotificationLoadingView extends StatelessWidget {
  const NotificationLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonLoader(
      builder: (context, skeletonColor) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            28 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 26,
                children: [
                  NotificationSkeletonSection(
                    headingWidth: 88,
                    color: skeletonColor,
                  ),
                  NotificationSkeletonSection(
                    headingWidth: 96,
                    color: skeletonColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NotificationSkeletonSection extends StatelessWidget {
  const NotificationSkeletonSection({
    super.key,
    required this.headingWidth,
    required this.color,
  });

  final double headingWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AppSkeletonBlock(
            width: headingWidth,
            height: 18,
            radius: 9,
            color: color,
          ),
        ),
        Column(
          spacing: 16,
          children: [
            NotificationSkeletonCard(color: color),
            NotificationSkeletonCard(color: color),
          ],
        ),
      ],
    );
  }
}

class NotificationSkeletonCard extends StatelessWidget {
  const NotificationSkeletonCard({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        spacing: 14,
        children: [
          AppSkeletonBlock(width: 56, height: 56, radius: 28, color: color),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 7,
              children: [
                Row(
                  children: [
                    AppSkeletonBlock(
                      width: 118,
                      height: 16,
                      radius: 8,
                      color: color,
                    ),
                    const Spacer(),
                    AppSkeletonBlock(
                      width: 58,
                      height: 10,
                      radius: 5,
                      color: color,
                    ),
                  ],
                ),
                AppSkeletonBlock(height: 13, radius: 7, color: color),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppSkeletonBlock(
                    width: 150,
                    height: 13,
                    radius: 7,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
