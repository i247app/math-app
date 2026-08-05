import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppResponsiveCardGroup extends StatelessWidget {
  const AppResponsiveCardGroup({
    super.key,
    required this.children,
    this.maxColumns = 2,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 12,
  }) : assert(maxColumns > 0);

  final List<Widget> children;
  final int maxColumns;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    if (children.length == 1) {
      return children.first;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = math.min(maxColumns, children.length);
        final totalSpacing = crossAxisSpacing * (columnCount - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columnCount;

        return Wrap(
          spacing: crossAxisSpacing,
          runSpacing: mainAxisSpacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
