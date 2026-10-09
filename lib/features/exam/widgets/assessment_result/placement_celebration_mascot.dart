import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

class PlacementCelebrationMascot extends StatefulWidget {
  const PlacementCelebrationMascot({super.key, required this.size});

  final double size;

  @override
  State<PlacementCelebrationMascot> createState() =>
      _PlacementCelebrationMascotState();
}

class _PlacementCelebrationMascotState extends State<PlacementCelebrationMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _mascotScale;
  late final Animation<double> _mascotOffsetY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _mascotScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.78, curve: Curves.easeOutBack),
    ).drive(Tween<double>(begin: 0.96, end: 1));
    _mascotOffsetY =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 12,
              end: -9,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 48,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: -9,
              end: 3,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 3,
              end: 0,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 22,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0, 0.8)),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        key: const ValueKey('placement-mascot'),
        dimension: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: 0,
              child: SizedBox(
                width: 0,
                height: 0,
                child: Stack(
                  children: [
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-stars'),
                      asset: 'assets/images/assessment-result-stars.png',
                      left: widget.size * 0.12,
                      top: 0,
                      dimension: widget.size * 0.76,
                      originOffset: Offset(0, widget.size * 0.075),
                      intervalStart: 0.05,
                    ),
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-numbers'),
                      asset: 'assets/images/assessment-result-numbers.png',
                      left: widget.size * 0.01,
                      top: widget.size * 0.43,
                      dimension: widget.size * 0.25,
                      originOffset: Offset(
                        widget.size * 0.07,
                        -widget.size * 0.015,
                      ),
                      intervalStart: 0.12,
                    ),
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-blocks'),
                      asset: 'assets/images/assessment-result-blocks.png',
                      left: widget.size * 0.035,
                      top: widget.size * 0.69,
                      dimension: widget.size * 0.25,
                      originOffset: Offset(
                        widget.size * 0.065,
                        -widget.size * 0.055,
                      ),
                      intervalStart: 0.2,
                    ),
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-checklist'),
                      asset: 'assets/images/assessment-result-checklist.png',
                      right: widget.size * 0.025,
                      top: widget.size * 0.43,
                      dimension: widget.size * 0.23,
                      originOffset: Offset(
                        -widget.size * 0.065,
                        -widget.size * 0.015,
                      ),
                      intervalStart: 0.16,
                    ),
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-pencil'),
                      asset: 'assets/images/assessment-result-pencil.png',
                      right: 0,
                      top: widget.size * 0.7,
                      dimension: widget.size * 0.25,
                      originOffset: Offset(
                        -widget.size * 0.07,
                        -widget.size * 0.055,
                      ),
                      intervalStart: 0.24,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _mascotOffsetY.value),
                  child: Transform.scale(
                    scale: _mascotScale.value,
                    child: child,
                  ),
                ),
                child: Image.asset(
                  'assets/images/assessment-result-mascot.png',
                  key: const ValueKey('placement-mascot-character'),
                  fit: BoxFit.contain,
                  cacheWidth: 520,
                  cacheHeight: 520,
                  filterQuality: FilterQuality.high,
                  semanticLabel: context.getText(AppKeys.placementResultLevel),
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/numi-mascot.png',
                    fit: BoxFit.contain,
                    cacheWidth: 520,
                    cacheHeight: 520,
                    filterQuality: FilterQuality.high,
                    semanticLabel: context.getText(
                      AppKeys.placementResultLevel,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBurstAsset({
    required Key key,
    required String asset,
    required double top,
    required double dimension,
    required Offset originOffset,
    required double intervalStart,
    double? left,
    double? right,
  }) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(intervalStart, 0.82, curve: Curves.easeOutBack),
    );

    return Positioned(
      left: left,
      right: right,
      top: top,
      width: dimension,
      height: dimension,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final progress = animation.value;
            return Opacity(
              opacity: progress.clamp(0, 1),
              child: Transform.translate(
                offset: originOffset * (1 - progress),
                child: Transform.scale(
                  scale: 0.95 + (0.05 * progress),
                  child: child,
                ),
              ),
            );
          },
          child: Image.asset(
            asset,
            key: key,
            fit: BoxFit.contain,
            cacheWidth: 360,
            cacheHeight: 360,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
