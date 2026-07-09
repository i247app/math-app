import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentAssessmentSkeletonPulse extends StatefulWidget {
  const ParentAssessmentSkeletonPulse({required this.builder});

  final Widget Function(BuildContext context, Color color) builder;

  @override
  State<ParentAssessmentSkeletonPulse> createState() =>
      _ParentAssessmentSkeletonPulseState();
}

class _ParentAssessmentSkeletonPulseState
    extends State<ParentAssessmentSkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
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
      builder: (context, _) => widget.builder(
        context,
        Color.lerp(
          const Color(0xFFF0F4F3),
          const Color(0xFFDCE7E5),
          _controller.value,
        )!,
      ),
    );
  }
}