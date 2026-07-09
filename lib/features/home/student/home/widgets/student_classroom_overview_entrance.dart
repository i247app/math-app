import 'package:flutter/material.dart';

class StudentClassroomOverviewEntrance extends StatefulWidget {
  const StudentClassroomOverviewEntrance({
    super.key,
    required this.order,
    required this.child,
    this.onFinished,
  });

  final int order;
  final Widget child;
  final VoidCallback? onFinished;

  @override
  State<StudentClassroomOverviewEntrance> createState() =>
      _StudentClassroomOverviewEntranceState();
}

class _StudentClassroomOverviewEntranceState
    extends State<StudentClassroomOverviewEntrance> {
  bool _isVisible = false;
  bool _hasNotifiedFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(
        Duration(milliseconds: 55 * widget.order.clamp(0, 8)),
      );
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  void _notifyFinished() {
    if (_hasNotifiedFinished) {
      return;
    }
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
          scale: _isVisible ? 1 : 0.94,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          onEnd: _isVisible ? _notifyFinished : null,
          child: widget.child,
        ),
      ),
    );
  }
}
