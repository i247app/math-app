part of '../role_tab_host.dart';

extension _RoleTabHostGestures on RoleTabHostState {
  void _handleHorizontalDragStart(DragStartDetails details) {
    if (_tabTransitionController.isAnimating) {
      return;
    }
    _isDragging = true;
    _dragOffset = 0;
    _dragNeighborTab = null;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || _dragWidth <= 0) {
      return;
    }

    var nextOffset = _dragOffset + details.delta.dx / _dragWidth;
    final isAtStartBoundary = widget.activeTab == 0 && nextOffset > 0;
    final isAtEndBoundary = widget.activeTab == 4 && nextOffset < 0;
    if (isAtStartBoundary || isAtEndBoundary) {
      nextOffset = 0;
    } else {
      nextOffset = nextOffset.clamp(-1.0, 1.0).toDouble();
    }

    final neighbor = nextOffset < 0
        ? widget.activeTab + 1
        : nextOffset > 0
        ? widget.activeTab - 1
        : null;
    final validNeighbor = neighbor != null && neighbor >= 0 && neighbor <= 4
        ? neighbor
        : null;

    _updateState(() {
      _dragOffset = nextOffset;
      _dragNeighborTab = validNeighbor;
      if (validNeighbor != null) {
        _visitedTabs.add(validNeighbor);
      }
    });
    widget.onSwipePositionChanged(widget.activeTab - _dragOffset);
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    _settleHorizontalDrag(details.velocity.pixelsPerSecond.dx);
  }

  void _handleHorizontalDragCancel() {
    _settleHorizontalDrag(0, forceCancel: true);
  }

  void _settleHorizontalDrag(
    double horizontalVelocity, {
    bool forceCancel = false,
  }) {
    if (!_isDragging) {
      return;
    }

    final neighbor = _dragNeighborTab;
    final progress = _dragOffset.abs().clamp(0.0, 1.0);
    final velocityFollowsDrag =
        horizontalVelocity.abs() >= 650 &&
        horizontalVelocity.sign == _dragOffset.sign;
    final completesSelection =
        !forceCancel &&
        neighbor != null &&
        (progress >= 0.24 || velocityFollowsDrag);

    _updateState(() {
      _isDragging = false;
      _isSettlingDrag = neighbor != null && progress > 0;
      _dragCompletesSelection = completesSelection;
      _dragSettleStartProgress = progress;
      if (neighbor != null) {
        _transitionFromTab = widget.activeTab;
        _transitionToTab = neighbor;
      }
    });

    if (!_isSettlingDrag) {
      widget.onSwipeInteractionEnded();
      return;
    }

    final remainingFraction = completesSelection ? 1 - progress : progress;
    final settleMilliseconds = (240 * remainingFraction)
        .round()
        .clamp(80, 240)
        .toInt();
    _tabTransitionController.duration = Duration(
      milliseconds: settleMilliseconds,
    );
    if (completesSelection) {
      _pendingDragTarget = neighbor;
    }
    _tabTransitionController.forward(from: 0);
    if (completesSelection) {
      widget.onSwipeToTab(neighbor);
    }
  }
}
