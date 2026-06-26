part of '../../../home_screen.dart';

class _ParentHomeLoadingCard extends StatefulWidget {
  const _ParentHomeLoadingCard();

  @override
  State<_ParentHomeLoadingCard> createState() => _ParentHomeLoadingCardState();
}

class _ParentHomeLoadingCardState extends State<_ParentHomeLoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
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
      builder: (context, _) {
        final pulseValue =
            0.5 - 0.5 * math.cos(math.pi * 2 * _controller.value);
        final color = Color.lerp(
          const Color(0xFFF1F3F3),
          const Color(0xFFE1E8E7),
          pulseValue,
        )!;

        return _ParentSkeletonShimmer(
          progress: _controller.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ParentSkeletonBlock(
                height: 225,
                radius: 30,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ParentSkeletonLine(
                        width: 148,
                        height: 30,
                        color: color,
                      ),
                      const SizedBox(height: 14),
                      _ParentSkeletonLine(
                        width: 210,
                        height: 34,
                        color: color,
                      ),
                      const Spacer(),
                      _ParentSkeletonLine(
                        width: 132,
                        height: 14,
                        color: color,
                      ),
                      const SizedBox(height: 12),
                      _ParentSkeletonBlock(
                        width: 150,
                        height: 44,
                        radius: 22,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ParentSkeletonBlock(
                      height: 160,
                      radius: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ParentSkeletonBlock(
                      height: 160,
                      radius: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ParentSkeletonBlock(
                height: 178,
                radius: 17,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (var index = 0; index < 3; index++) ...[
                        Row(
                          children: [
                            _ParentSkeletonBlock(
                              width: 32,
                              height: 32,
                              radius: 10,
                              color: color,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ParentSkeletonLine(
                                    width: index == 0 ? 120 : 150,
                                    height: 14,
                                    color: color,
                                  ),
                                  const SizedBox(height: 7),
                                  _ParentSkeletonLine(
                                    width: double.infinity,
                                    height: 10,
                                    color: color,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (index != 2) const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
