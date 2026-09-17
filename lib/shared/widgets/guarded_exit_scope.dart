import 'package:flutter/material.dart';

class GuardedExitController<T> {
  _GuardedExitScopeState<T>? _state;

  Future<void> requestExit() {
    return _state?._requestExit() ?? Future<void>.value();
  }

  Future<void> exit() {
    final state = _state;
    return state?._exit(state.widget.exitResult) ?? Future<void>.value();
  }

  Future<void> exitWithResult(T? result) {
    return _state?._exit(result) ?? Future<void>.value();
  }

  void _attach(_GuardedExitScopeState<T> state) {
    _state = state;
  }

  void _detach(_GuardedExitScopeState<T> state) {
    if (identical(_state, state)) {
      _state = null;
    }
  }
}

class GuardedExitScope<T> extends StatefulWidget {
  const GuardedExitScope({
    super.key,
    required this.controller,
    required this.shouldConfirm,
    required this.confirmExit,
    required this.child,
    this.isExitBlocked = false,
    this.exitResult,
  });

  final GuardedExitController<T> controller;
  final bool shouldConfirm;
  final bool isExitBlocked;
  final Future<bool> Function(BuildContext context) confirmExit;
  final T? exitResult;
  final Widget child;

  @override
  State<GuardedExitScope<T>> createState() => _GuardedExitScopeState<T>();
}

class _GuardedExitScopeState<T> extends State<GuardedExitScope<T>> {
  static const double _backSwipeTriggerDistance = 48;
  static const double _backSwipeTriggerVelocity = 350;

  bool _allowPop = false;
  bool _isConfirming = false;
  double _backSwipeDistance = 0;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
  }

  @override
  void didUpdateWidget(covariant GuardedExitScope<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller._detach(this);
      widget.controller._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    super.dispose();
  }

  Future<void> _requestExit() async {
    if (!mounted || _allowPop || _isConfirming || widget.isExitBlocked) {
      return;
    }

    if (!widget.shouldConfirm) {
      await _exit(widget.exitResult);
      return;
    }

    _isConfirming = true;
    final shouldExit = await widget.confirmExit(context);
    _isConfirming = false;
    if (shouldExit && mounted) {
      await _exit(widget.exitResult);
    }
  }

  Future<void> _exit(T? result) async {
    if (!mounted || _allowPop) {
      return;
    }
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      Navigator.of(context).pop<T>(result);
    }
  }

  void _handleBackSwipeStart(DragStartDetails _) {
    _backSwipeDistance = 0;
  }

  void _handleBackSwipeUpdate(DragUpdateDetails details) {
    _backSwipeDistance += details.primaryDelta ?? 0;
  }

  void _handleBackSwipeEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldRequestExit =
        _backSwipeDistance >= _backSwipeTriggerDistance ||
        velocity >= _backSwipeTriggerVelocity;
    _backSwipeDistance = 0;
    if (shouldRequestExit) {
      _requestExit();
    }
  }

  void _handleBackSwipeCancel() {
    _backSwipeDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final needsIosBackSwipeDetector =
        Theme.of(context).platform == TargetPlatform.iOS &&
        widget.shouldConfirm &&
        !widget.isExitBlocked;

    return PopScope<T>(
      canPop: _allowPop || (!widget.shouldConfirm && !widget.isExitBlocked),
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await _requestExit();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (needsIosBackSwipeDetector)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 24,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                excludeFromSemantics: true,
                onHorizontalDragStart: _handleBackSwipeStart,
                onHorizontalDragUpdate: _handleBackSwipeUpdate,
                onHorizontalDragEnd: _handleBackSwipeEnd,
                onHorizontalDragCancel: _handleBackSwipeCancel,
              ),
            ),
        ],
      ),
    );
  }
}
