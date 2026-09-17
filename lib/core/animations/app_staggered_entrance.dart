import 'dart:async';

import 'package:flutter/material.dart';

class AppStaggeredEntrance extends StatefulWidget {
  const AppStaggeredEntrance({
    super.key,
    required this.order,
    required this.child,
    this.initialScale = 0.94,
    this.delayStep = const Duration(milliseconds: 55),
    this.maxOrder = 8,
    this.initiallyVisible = false,
    this.onFinished,
  });

  final int order;
  final Widget child;
  final double initialScale;
  final Duration delayStep;
  final int maxOrder;
  final bool initiallyVisible;
  final VoidCallback? onFinished;

  @override
  State<AppStaggeredEntrance> createState() => _AppStaggeredEntranceState();
}

class _AppStaggeredEntranceState extends State<AppStaggeredEntrance> {
  late bool _isVisible;
  bool _hasNotifiedFinished = false;
  Timer? _entranceTimer;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.initiallyVisible;
    if (_isVisible) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final multiplier = widget.order.clamp(0, widget.maxOrder);
      final delay = widget.delayStep * multiplier;
      if (delay == Duration.zero) {
        _show();
        return;
      }
      _entranceTimer = Timer(delay, _show);
    });
  }

  void _show() {
    if (!mounted) return;
    setState(() => _isVisible = true);
  }

  @override
  void dispose() {
    _entranceTimer?.cancel();
    super.dispose();
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
