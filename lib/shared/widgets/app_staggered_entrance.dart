import 'package:flutter/material.dart';

class AppStaggeredEntrance extends StatefulWidget {
  const AppStaggeredEntrance({
    super.key,
    required this.order,
    required this.child,
    this.initialScale = 0.94,
    this.delayStep = const Duration(milliseconds: 55),
    this.maxOrder = 8,
    this.onFinished,
  });

  final int order;
  final Widget child;
  final double initialScale;
  final Duration delayStep;
  final int maxOrder;
  final VoidCallback? onFinished;

  @override
  State<AppStaggeredEntrance> createState() => _AppStaggeredEntranceState();
}

class _AppStaggeredEntranceState extends State<AppStaggeredEntrance> {
  bool _isVisible = false;
  bool _hasNotifiedFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final multiplier = widget.order.clamp(0, widget.maxOrder);
      await Future<void>.delayed(widget.delayStep * multiplier);
      if (mounted) setState(() => _isVisible = true);
    });
  }

  void _notifyFinished() {
    if (_hasNotifiedFinished) return;
    _hasNotifiedFinished = true;
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _notifyFinished());
      return widget.child;
    }

    return AnimatedOpacity(
      opacity: _isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : const Offset(0, 0.055),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _isVisible ? 1 : widget.initialScale,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          onEnd: _isVisible ? _notifyFinished : null,
          child: widget.child,
        ),
      ),
    );
  }
}
