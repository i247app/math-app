import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/history_tab/history_loading_state.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_skeleton_card.dart';

class HistoryLoadingStateState extends State<HistoryLoadingState>
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
      child: Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            HistorySkeletonCard(scale: widget.scale),
            if (index != 2) SizedBox(height: 14 * widget.scale),
          ],
        ],
      ),
    );
  }
}
