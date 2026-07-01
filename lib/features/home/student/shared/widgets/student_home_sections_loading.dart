part of '../../../home_screen.dart';

class _StudentHomeSectionsLoading extends StatefulWidget {
  const _StudentHomeSectionsLoading();

  @override
  State<_StudentHomeSectionsLoading> createState() =>
      _StudentHomeSectionsLoadingState();
}

class _StudentHomeSectionsLoadingState
    extends State<_StudentHomeSectionsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Colors.white.withValues(alpha: 0.72),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0.28, 0.5, 0.72],
          ).createShader(Rect.fromLTWH(dx, 0, shimmerWidth, bounds.height));
        },
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 116,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE4EAEC)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StudentClassroomSkeletonBlock(
                  width: 150,
                  height: 15,
                  radius: 7,
                ),
                SizedBox(height: 12),
                _StudentClassroomSkeletonBlock(height: 56, radius: 14),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              for (var index = 0; index < 2; index++) ...[
                const Expanded(
                  child: _StudentClassroomSkeletonBlock(
                    height: 138,
                    radius: 18,
                  ),
                ),
                if (index == 0) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 20),
          const _StudentClassroomSkeletonBlock(
            width: 170,
            height: 18,
            radius: 8,
          ),
          const SizedBox(height: 10),
          const _StudentClassroomSkeletonBlock(height: 104, radius: 18),
        ],
      ),
    );
  }
}
