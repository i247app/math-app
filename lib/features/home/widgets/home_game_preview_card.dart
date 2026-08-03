import 'package:flutter/material.dart';

class HomeGamePreviewCard extends StatelessWidget {
  const HomeGamePreviewCard({
    super.key,
    required this.background,
    this.height = 150,
    this.asset,
    this.child,
  });

  final String? asset;
  final Color background;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ColoredBox(
        color: background,
        child:
            child ??
            Image.asset(
              asset!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
      ),
    );
  }
}
