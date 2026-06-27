import 'package:flutter/material.dart';

class AccountScreenSkeleton extends StatefulWidget {
  const AccountScreenSkeleton({super.key, required this.scale});

  final double scale;

  @override
  State<AccountScreenSkeleton> createState() => _AccountScreenSkeletonState();
}

class _AccountScreenSkeletonState extends State<AccountScreenSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          final shimmerWidth = bounds.width * 1.2;
          final start = -shimmerWidth;
          final dx = start + (bounds.width - start) * _controller.value;
          return LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.78),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0.28, 0.5, 0.72],
          ).createShader(
            Rect.fromLTWH(dx, 0, shimmerWidth, bounds.height),
          );
        },
        child: child,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _AccountSkeletonBlock(
              width: 36 * scale,
              height: 36 * scale,
              radius: 10 * scale,
            ),
          ),
          SizedBox(height: 10 * scale),
          _AccountSkeletonBlock(
            width: 126 * scale,
            height: 126 * scale,
            radius: 63 * scale,
          ),
          SizedBox(height: 24 * scale),
          for (var index = 0; index < 3; index++) ...[
            _AccountSkeletonBlock(
              height: 68 * scale,
              radius: 16 * scale,
            ),
            if (index < 2) SizedBox(height: 20 * scale),
          ],
        ],
      ),
    );
  }
}

class _AccountSkeletonBlock extends StatelessWidget {
  const _AccountSkeletonBlock({
    this.width,
    required this.height,
    required this.radius,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
