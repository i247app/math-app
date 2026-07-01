part of '../../../home_screen.dart';

class _StudentClassroomLoadingRegion extends StatefulWidget {
  const _StudentClassroomLoadingRegion();

  @override
  State<_StudentClassroomLoadingRegion> createState() =>
      _StudentClassroomLoadingRegionState();
}

class _StudentClassroomLoadingRegionState
    extends State<_StudentClassroomLoadingRegion>
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
    return ColoredBox(
      color: Colors.white,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              final shimmerWidth = bounds.width * 1.2;
              final start = -shimmerWidth;
              final end = bounds.width;
              final dx = start + (end - start) * _controller.value;
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
          );
        },
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Row(
              children: [
                for (var index = 0; index < 2; index++) ...[
                  const Expanded(
                    child: _StudentClassroomSkeletonBlock(
                      height: 118,
                      radius: 22,
                    ),
                  ),
                  if (index == 0) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 30),
            const _StudentClassroomSkeletonBlock(
              width: 210,
              height: 30,
              radius: 12,
            ),
            const SizedBox(height: 14),
            const _StudentClassroomSkeletonBlock(height: 48, radius: 20),
            const SizedBox(height: 14),
            Container(
              height: 205,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6FFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E7E8)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StudentClassroomSkeletonBlock(
                    width: 92,
                    height: 18,
                    radius: 8,
                  ),
                  SizedBox(height: 8),
                  _StudentClassroomSkeletonBlock(height: 43, radius: 8),
                  SizedBox(height: 14),
                  _StudentClassroomSkeletonBlock(
                    width: 45,
                    height: 18,
                    radius: 8,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StudentClassroomSkeletonBlock(
                          height: 30,
                          radius: 15,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _StudentClassroomSkeletonBlock(
                          height: 30,
                          radius: 15,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _StudentClassroomSkeletonBlock(
                          height: 30,
                          radius: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _StudentClassroomSkeletonBlock(
              width: 170,
              height: 24,
              radius: 10,
            ),
            const SizedBox(height: 12),
            const _StudentClassroomSkeletonBlock(height: 120, radius: 16),
          ],
        ),
      ),
    );
  }
}
