import 'package:flutter/material.dart';

import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_factory.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';

part 'role_tab_host/gestures.dart';
part 'role_tab_host/tab_builder.dart';

class RoleTabHost extends StatefulWidget {
  const RoleTabHost({
    super.key,
    required this.activeTab,
    required this.tabFactory,
    required this.selectionRevision,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.activeRole,
    required this.profileLoadError,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.initialGrades,
    required this.gradeService,
    required this.classroomService,
    required this.assignmentService,
    required this.quizService,
    required this.onLogout,
    required this.onAddProfileFromPractice,
    required this.onProfileSaved,
    required this.openAddProfileRequestId,
    required this.onCompleteTeacherProfile,
    required this.onOpenClassroomTab,
    required this.onOpenPracticeTab,
    required this.onOpenProfileMenu,
    required this.onParentAssessmentStateChanged,
    required this.profileResetSignal,
    required this.bottomPadding,
    required this.hasUnreadNotifications,
    required this.onNotificationTap,
    required this.showChildProfileDialogOnStart,
    required this.onSwipeToTab,
    required this.onSwipePositionChanged,
    required this.onSwipeInteractionEnded,
    this.onChildProfileDialogShown,
    this.homeHeader,
  });

  final int activeTab;
  final DashboardTabFactory tabFactory;
  final int selectionRevision;
  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final ClassroomService classroomService;
  final ClassroomExerciseService assignmentService;
  final QuizService quizService;
  final VoidCallback onLogout;
  final VoidCallback onAddProfileFromPractice;
  final VoidCallback onProfileSaved;
  final int openAddProfileRequestId;
  final Future<void> Function() onCompleteTeacherProfile;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenPracticeTab;
  final VoidCallback onOpenProfileMenu;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final int profileResetSignal;
  final double bottomPadding;
  final bool hasUnreadNotifications;
  final VoidCallback onNotificationTap;
  final bool showChildProfileDialogOnStart;
  final ValueChanged<int> onSwipeToTab;
  final ValueChanged<double> onSwipePositionChanged;
  final VoidCallback onSwipeInteractionEnded;
  final VoidCallback? onChildProfileDialogShown;
  final Widget? homeHeader;

  @override
  State<RoleTabHost> createState() => RoleTabHostState();
}

class RoleTabHostState extends State<RoleTabHost>
    with SingleTickerProviderStateMixin {
  static const _tabTransitionDuration = Duration(milliseconds: 240);

  late final Set<int> _visitedTabs = <int>{widget.activeTab};
  final Map<int, int> _activationTicks = <int, int>{};
  final Map<int, Widget> _tabChildren = <int, Widget>{};
  late final AnimationController _tabTransitionController;
  late int _transitionFromTab = widget.activeTab;
  late int _transitionToTab = widget.activeTab;
  late int _lastProfileResetSignal = widget.profileResetSignal;
  bool _isDragging = false;
  bool _isSettlingDrag = false;
  bool _dragCompletesSelection = false;
  double _dragOffset = 0;
  double _dragWidth = 1;
  double _dragSettleStartProgress = 0;
  int? _dragNeighborTab;
  int? _pendingDragTarget;

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
    _activationTicks[widget.activeTab] = 1;
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
    widget.onSwipePositionChanged(
      _transitionFromTab + (_transitionToTab - _transitionFromTab) * progress,
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
    await Future<void>.delayed(const Duration(milliseconds: 300));
    const tabOrder = <int>[1, 2, 3, 4, 0];
    for (final tab in tabOrder) {
      if (!mounted) {
        return;
      }
      if (tab == widget.activeTab || _visitedTabs.contains(tab)) {
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
    final activeTabChanged = oldWidget.activeTab != widget.activeTab;
    if (activeTabChanged) {
      final continuesDragTransition =
          _pendingDragTarget == widget.activeTab &&
          _transitionFromTab == oldWidget.activeTab;
      _pendingDragTarget = null;
      if (!continuesDragTransition) {
        if (_isDragging || _isSettlingDrag) {
          _isDragging = false;
          _isSettlingDrag = false;
          widget.onSwipeInteractionEnded();
        }
        _transitionFromTab = oldWidget.activeTab;
        _transitionToTab = widget.activeTab;
      }
      _visitedTabs.add(widget.activeTab);
      // Rebuild the incoming tab immediately. The outgoing tab stays intact
      // until the transition completes so its layout cannot change mid-swipe.
      _tabChildren.remove(widget.activeTab);
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
    } else if ((!activeTabChanged || _transitionFromTab != 0) &&
        (oldWidget.homeHeader != widget.homeHeader ||
            oldWidget.hasUnreadNotifications !=
                widget.hasUnreadNotifications)) {
      // The header only belongs to the Home tab and can change when the
      // profile menu opens or the unread notification state changes.
      _tabChildren.remove(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxTabIndex = 4;
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
                    for (var tab = 0; tab <= maxTabIndex; tab++)
                      if (_visitedTabs.contains(tab))
                        Offstage(
                          key: ValueKey('home-tab-$tab'),
                          offstage: !_isTabVisible(tab, isTransitioning),
                          child: TickerMode(
                            enabled: _isTabVisible(tab, isTransitioning),
                            child: IgnorePointer(
                              ignoring:
                                  _isDragging ||
                                  isTransitioning ||
                                  tab != widget.activeTab,
                              child: FractionalTranslation(
                                translation: Offset(
                                  _horizontalOffsetFor(tab, isTransitioning),
                                  0,
                                ),
                                child: KeyedSubtree(
                                  key: ValueKey('home-dashboard-content-$tab'),
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

  bool _isTabVisible(int tab, bool isTransitioning) {
    if (_isDragging) {
      return tab == widget.activeTab || tab == _dragNeighborTab;
    }
    if (!isTransitioning) {
      return tab == widget.activeTab;
    }
    return tab == _transitionFromTab || tab == _transitionToTab;
  }

  double _horizontalOffsetFor(int tab, bool isTransitioning) {
    if (_isDragging) {
      if (tab == widget.activeTab) {
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
    final movesForward = _transitionToTab > _transitionFromTab;
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
      previous.user != current.user ||
      previous.profiles != current.profiles ||
      previous.activeProfile != current.activeProfile ||
      previous.profileLoadError != current.profileLoadError ||
      previous.initialGrades != current.initialGrades ||
      previous.bottomPadding != current.bottomPadding;
}
