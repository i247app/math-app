import 'package:flutter/material.dart';

import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_factory.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_order.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';

part 'role_tab_host/gestures.dart';
part 'role_tab_host/tab_builder.dart';

class RoleTabHost extends StatefulWidget {
  const RoleTabHost({
    super.key,
    required this.args,
    required this.tabFactory,
    required this.activeRole,
    required this.profileResetSignal,
    required this.onSwipeToTab,
    required this.onSwipePositionChanged,
    required this.onSwipeInteractionEnded,
  });

  final DashboardTabArgs args;
  final DashboardTabFactory tabFactory;
  final ProfileRole activeRole;
  final int profileResetSignal;
  final ValueChanged<DashboardTabId> onSwipeToTab;
  final ValueChanged<double?> onSwipePositionChanged;
  final VoidCallback onSwipeInteractionEnded;

  @override
  State<RoleTabHost> createState() => RoleTabHostState();
}

class RoleTabHostState extends State<RoleTabHost>
    with SingleTickerProviderStateMixin {
  static const _tabTransitionDuration = Duration(milliseconds: 240);

  late final Set<DashboardTabId> _visitedTabs = <DashboardTabId>{
    widget.args.activeTab,
  };
  final Map<DashboardTabId, int> _activationTicks = <DashboardTabId, int>{};
  final Map<DashboardTabId, Widget> _tabChildren = <DashboardTabId, Widget>{};
  late final AnimationController _tabTransitionController;
  late DashboardTabId _transitionFromTab = widget.args.activeTab;
  late DashboardTabId _transitionToTab = widget.args.activeTab;
  late int _lastProfileResetSignal = widget.profileResetSignal;
  int _prewarmRevision = 0;
  bool _isDragging = false;
  bool _isSettlingDrag = false;
  bool _dragCompletesSelection = false;
  double _dragOffset = 0;
  double _dragWidth = 1;
  double _dragSettleStartProgress = 0;
  DashboardTabId? _dragNeighborTab;
  DashboardTabId? _pendingDragTarget;

  @override
  void initState() {
    super.initState();
    _tabTransitionController =
        AnimationController(
            vsync: this,
            duration: _tabTransitionDuration,
            value: 1,
          )
          ..addListener(_handleTabTransitionTick)
          ..addStatusListener(_handleTabTransitionStatus);
    _activationTicks[widget.args.activeTab] = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) => _prewarmTabs());
  }

  @override
  void dispose() {
    _tabTransitionController.removeListener(_handleTabTransitionTick);
    _tabTransitionController.removeStatusListener(_handleTabTransitionStatus);
    _tabTransitionController.dispose();
    super.dispose();
  }

  void _handleTabTransitionTick() {
    if (!_isSettlingDrag) {
      return;
    }
    final progress = _resolvedTransitionProgress();
    final visibleTabs = visibleDashboardTabs(widget.activeRole);
    final fromPosition = visibleTabs.indexOf(_transitionFromTab);
    final toPosition = visibleTabs.indexOf(_transitionToTab);
    widget.onSwipePositionChanged(
      fromPosition + (toPosition - fromPosition) * progress,
    );
  }

  void _handleTabTransitionStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {
        // Keep the outgoing widget completely unchanged while it slides away.
        // Rebuild it only after it is offstage so removing the Home header
        // cannot make the content jump upward during the transition.
        _tabChildren.remove(_transitionFromTab);
      });
      if (_isSettlingDrag) {
        _isSettlingDrag = false;
        _tabTransitionController.duration = _tabTransitionDuration;
        widget.onSwipeInteractionEnded();
      }
    }
  }

  Future<void> _prewarmTabs() async {
    final revision = ++_prewarmRevision;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted || revision != _prewarmRevision) return;
    final tabOrder = [
      ...visibleDashboardTabs(
        widget.activeRole,
      ).where((tab) => tab != DashboardTabId.home),
      DashboardTabId.home,
    ];
    for (final tab in tabOrder) {
      if (!mounted || revision != _prewarmRevision) {
        return;
      }
      if (tab == widget.args.activeTab || _visitedTabs.contains(tab)) {
        continue;
      }

      setState(() {
        _visitedTabs.add(tab);
        _activationTicks[tab] = 0;
      });
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void didUpdateWidget(covariant RoleTabHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeRole != widget.activeRole) {
      _tabTransitionController.stop();
      _isDragging = false;
      _isSettlingDrag = false;
      _pendingDragTarget = null;
      _dragNeighborTab = null;
      _transitionFromTab = widget.args.activeTab;
      _transitionToTab = widget.args.activeTab;
      _visitedTabs
        ..clear()
        ..add(widget.args.activeTab);
      _activationTicks
        ..clear()
        ..[widget.args.activeTab] = 1;
      _tabChildren.clear();
      _lastProfileResetSignal = widget.profileResetSignal;
      _prewarmTabs();
      return;
    }
    final activeTabChanged = oldWidget.args.activeTab != widget.args.activeTab;
    if (activeTabChanged) {
      final continuesDragTransition =
          _pendingDragTarget == widget.args.activeTab &&
          _transitionFromTab == oldWidget.args.activeTab;
      _pendingDragTarget = null;
      if (!continuesDragTransition) {
        if (_isDragging || _isSettlingDrag) {
          _isDragging = false;
          _isSettlingDrag = false;
          widget.onSwipeInteractionEnded();
        }
        _transitionFromTab = oldWidget.args.activeTab;
        _transitionToTab = widget.args.activeTab;
      }
      _visitedTabs.add(widget.args.activeTab);
      // Rebuild the incoming tab immediately. The outgoing tab stays intact
      // until the transition completes so its layout cannot change mid-swipe.
      _tabChildren.remove(widget.args.activeTab);
      if (!continuesDragTransition) {
        _tabTransitionController.duration = _tabTransitionDuration;
        _tabTransitionController.forward(from: 0);
      }
    }

    if (widget.profileResetSignal != _lastProfileResetSignal) {
      _lastProfileResetSignal = widget.profileResetSignal;
      for (final tab in _activationTicks.keys.toList()) {
        _activationTicks[tab] = (_activationTicks[tab] ?? 0) + 1;
      }
      _tabChildren.clear();
      return;
    }

    if (_requiresAllTabsRebuild(oldWidget, widget)) {
      _tabChildren.clear();
    } else if ((!activeTabChanged ||
            _transitionFromTab != DashboardTabId.home) &&
        (oldWidget.args.presentation.homeHeader !=
                widget.args.presentation.homeHeader ||
            oldWidget.args.presentation.hasUnreadNotifications !=
                widget.args.presentation.hasUnreadNotifications)) {
      // Keep the outgoing Home header intact until its slide completes.
      _tabChildren.remove(DashboardTabId.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _dragWidth = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _handleHorizontalDragStart,
          onHorizontalDragUpdate: _handleHorizontalDragUpdate,
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          onHorizontalDragCancel: _handleHorizontalDragCancel,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _tabTransitionController,
              builder: (context, _) {
                final isTransitioning = _tabTransitionController.isAnimating;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    for (final tab in supportedDashboardTabs(widget.activeRole))
                      if (_visitedTabs.contains(tab))
                        Offstage(
                          key: ValueKey(
                            'home-tab-${dashboardTabWidgetKeySuffix(widget.activeRole, tab)}',
                          ),
                          offstage: !_isTabVisible(tab, isTransitioning),
                          child: TickerMode(
                            enabled: _isTabVisible(tab, isTransitioning),
                            child: IgnorePointer(
                              ignoring:
                                  _isDragging ||
                                  isTransitioning ||
                                  tab != widget.args.activeTab,
                              child: FractionalTranslation(
                                translation: Offset(
                                  _horizontalOffsetFor(tab, isTransitioning),
                                  0,
                                ),
                                child: KeyedSubtree(
                                  key: ValueKey(
                                    'home-dashboard-content-${dashboardTabWidgetKeySuffix(widget.activeRole, tab)}',
                                  ),
                                  child: _tabChildren.putIfAbsent(
                                    tab,
                                    () => _buildTab(context, tab),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  bool _isTabVisible(DashboardTabId tab, bool isTransitioning) {
    if (_isDragging) {
      return tab == widget.args.activeTab || tab == _dragNeighborTab;
    }
    if (!isTransitioning) {
      return tab == widget.args.activeTab;
    }
    return tab == _transitionFromTab || tab == _transitionToTab;
  }

  double _horizontalOffsetFor(DashboardTabId tab, bool isTransitioning) {
    if (_isDragging) {
      if (tab == widget.args.activeTab) {
        return _dragOffset;
      }
      if (tab == _dragNeighborTab) {
        return _dragOffset < 0 ? 1 + _dragOffset : _dragOffset - 1;
      }
      return 0;
    }
    if (!isTransitioning) {
      return 0;
    }

    final progress = _resolvedTransitionProgress();
    final movesForward = isForwardVisibleTabTransition(
      widget.activeRole,
      _transitionFromTab,
      _transitionToTab,
    );
    if (tab == _transitionFromTab) {
      return movesForward ? -progress : progress;
    }
    if (tab == _transitionToTab) {
      return movesForward ? 1 - progress : progress - 1;
    }
    return 0;
  }

  double _resolvedTransitionProgress() {
    final animationProgress = Curves.easeOutCubic.transform(
      _tabTransitionController.value,
    );
    if (!_isSettlingDrag) {
      return animationProgress;
    }
    return _dragSettleStartProgress +
        ((_dragCompletesSelection ? 1.0 : 0.0) - _dragSettleStartProgress) *
            animationProgress;
  }

  void _updateState(VoidCallback update) => setState(update);
}

bool _requiresAllTabsRebuild(RoleTabHost previous, RoleTabHost current) {
  return previous.activeRole != current.activeRole ||
      previous.args.session.user != current.args.session.user ||
      previous.args.session.profiles != current.args.session.profiles ||
      previous.args.session.activeProfile !=
          current.args.session.activeProfile ||
      previous.args.session.profileLoadError !=
          current.args.session.profileLoadError ||
      previous.args.session.initialGrades !=
          current.args.session.initialGrades ||
      previous.args.presentation.bottomPadding !=
          current.args.presentation.bottomPadding;
}
