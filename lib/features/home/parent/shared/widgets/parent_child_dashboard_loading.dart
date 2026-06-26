part of '../../../home_screen.dart';

class _ParentChildDashboardLoading extends StatefulWidget {
  const _ParentChildDashboardLoading();

  @override
  State<_ParentChildDashboardLoading> createState() =>
      _ParentChildDashboardLoadingState();
}

class _ParentChildDashboardLoadingState
    extends State<_ParentChildDashboardLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(
          const Color(0xFFF1F3F3),
          const Color(0xFFE1E8E7),
          _controller.value,
        )!;
        return Column(
          children: [
            Row(
              children: [
                for (var index = 0; index < 2; index++) ...[
                  Expanded(
                    child: _ParentSkeletonBlock(
                      height: 121,
                      radius: 18,
                      color: color,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 22,
                        ),
                        child: Column(
                          children: [
                            _ParentSkeletonLine(
                              width: 70,
                              height: 12,
                              color: color,
                            ),
                            const SizedBox(height: 12),
                            _ParentSkeletonLine(
                              width: 88,
                              height: 28,
                              color: color,
                            ),
                            const SizedBox(height: 12),
                            _ParentSkeletonLine(
                              width: 96,
                              height: 10,
                              color: color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index == 0) const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < 2; index++) ...[
              _ParentSkeletonBlock(
                height: 98,
                radius: 18,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      _ParentSkeletonBlock(
                        width: 50,
                        height: 50,
                        radius: 25,
                        color: color,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ParentSkeletonLine(
                              width: 94,
                              height: 10,
                              color: color,
                            ),
                            const SizedBox(height: 10),
                            _ParentSkeletonLine(
                              width: double.infinity,
                              height: 16,
                              color: color,
                            ),
                            const SizedBox(height: 8),
                            _ParentSkeletonLine(
                              width: 120,
                              height: 10,
                              color: color,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            for (var index = 0; index < 2; index++) ...[
              _ParentSkeletonBlock(
                height: 190,
                radius: 22,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _ParentSkeletonBlock(
                            width: 48,
                            height: 48,
                            radius: 13,
                            color: color,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ParentSkeletonLine(
                                  width: 135,
                                  height: 15,
                                  color: color,
                                ),
                                const SizedBox(height: 8),
                                _ParentSkeletonLine(
                                  width: 70,
                                  height: 9,
                                  color: color,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _ParentSkeletonBlock(
                          radius: 13,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index == 0) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}
