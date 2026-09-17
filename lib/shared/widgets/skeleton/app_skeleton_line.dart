import 'package:flutter/material.dart';

/// A left-aligned horizontal line used as a text placeholder in skeletons.
///
/// Replaces [_ParentSkeletonLine].
class AppSkeletonLine extends StatelessWidget {
  const AppSkeletonLine({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height),
        ),
      ),
    );
  }
}
