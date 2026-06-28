part of '../../home_screen.dart';

class ParentRoomTab extends StatefulWidget {
  const ParentRoomTab({super.key, required this.args});

  final HomeDashboardArgs args;

  @override
  State<ParentRoomTab> createState() => _ParentRoomTabState();
}

class _ParentRoomTabState extends State<ParentRoomTab> {
  late final HomeLayoutService _homeLayoutService = HomeLayoutApi();

  HomeLayout? _layout;
  bool _isLoading = true;
  bool _hasLoaded = false;
  String? _errorMessage;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.args.isActive) {
      _loadLayout();
    }
  }

  @override
  void didUpdateWidget(covariant ParentRoomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.args.isActive && widget.args.isActive) {
      _loadLayout();
      return;
    }
    if (!widget.args.isActive) {
      return;
    }
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.args.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.args.activeProfile,
    );
    if (oldProfileId != profileId ||
        oldWidget.args.activeRefreshTick != widget.args.activeRefreshTick) {
      _loadLayout(forceRefresh: true);
    }
  }

  Future<void> _loadLayout({bool forceRefresh = false}) async {
    final requestId = ++_requestId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.args.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      if (!mounted) {
        return;
      }
      setState(() {
        _layout = null;
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = null;
      });
      return;
    }

    final cache = HomeProfileCache.instance;
    final cachedSnapshot = cache.getParent(profileId);
    if (!forceRefresh && cachedSnapshot != null) {
      setState(() => _applySnapshot(cachedSnapshot));
      if (!cachedSnapshot.isStale) {
        return;
      }
    }

    final hadRenderableContent = _hasLoaded;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final layout = await _homeLayoutService.getLayout(profileId: profileId);
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _layout = layout;
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = null;
      });
      cache.putParent(
        ParentHomeSnapshot(
          profileId: profileId,
          homeLayout: layout,
          completedAssessments: _quizzesFromLayoutQuizzes(layout.quizzes),
          cachedAt: DateTime.now(),
        ),
      );
    } on HomeLayoutException catch (error) {
      if (!mounted) {
        return;
      }
      if (hadRenderableContent) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.message;
        });
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (hadRenderableContent) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              context.readText(AppKeys.parentChildDashboardLoadFailed);
        });
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage =
            context.readText(AppKeys.parentChildDashboardLoadFailed);
      });
    }
  }

  void _applySnapshot(ParentHomeSnapshot snapshot) {
    _layout = snapshot.homeLayout;
    _isLoading = false;
    _hasLoaded = true;
    _errorMessage = null;
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.args.scale;
    final topInset = MediaQuery.paddingOf(context).top;
    final parent = _layout?.parent;
    final entries = _roomEntries(parent);
    final pendingExercises =
        parent?.pendingExercises ?? const <HomeLayoutPendingExercise>[];
    final expiredExercises =
        parent?.expiredExercises ?? const <HomeLayoutPendingExercise>[];
    final completions =
        parent?.recentCompletions ?? const <HomeLayoutRecentCompletion>[];

    return ColoredBox(
      color: const Color(0xFFF8FAFA),
      child: Column(
        children: [
          HomeTabHeader(
            title: context.getText(AppKeys.navRoom),
            topInset: topInset,
            scale: scale,
          ),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF339395),
              onRefresh: () => _loadLayout(forceRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  14 * scale,
                  24 * scale,
                  14 * scale,
                  widget.args.bottomPadding + 24 * scale,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _roomContent(
                    context,
                    entries: entries,
                    pendingExercises: pendingExercises,
                    expiredExercises: expiredExercises,
                    completions: completions,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomContent(
    BuildContext context, {
    required List<_ParentRoomEntry> entries,
    required List<HomeLayoutPendingExercise> pendingExercises,
    required List<HomeLayoutPendingExercise> expiredExercises,
    required List<HomeLayoutRecentCompletion> completions,
  }) {
    if (_isLoading && !_hasLoaded) {
      return const _ParentRoomLoading(key: ValueKey('room-loading'));
    }

    if (_errorMessage != null && entries.isEmpty) {
      return _ParentRoomStateCard(
        key: const ValueKey('room-error'),
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.historyLoadErrorTitle),
        message: _errorMessage!,
        onTap: () => _loadLayout(forceRefresh: true),
      );
    }

    if (entries.isEmpty) {
      return _ParentRoomStateCard(
        key: const ValueKey('room-empty'),
        icon: Icons.meeting_room_outlined,
        title: context.getText(AppKeys.parentNoClassroom),
        message: context.getText(AppKeys.parentJoinRoomSubtitle),
        onTap: _loadLayout,
      );
    }

    return Column(
      key: const ValueKey('room-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ParentRoomClassGrid(
          entries: entries,
          onTap: _openRoomDetail,
        ),
        const SizedBox(height: 18),
        _ParentRoomListSection(
          title: context.formatText(AppKeys.parentTasksCountTitle, {
            'count': pendingExercises.length + expiredExercises.length,
          }),
          onViewAll: widget.args.onOpenClassroomTab,
          child: pendingExercises.isEmpty && expiredExercises.isEmpty
              ? _ParentEmptyTaskLine(
                  icon: Icons.assignment_turned_in_outlined,
                  text: context.getText(AppKeys.studentNoHomeworkTitle),
                )
              : Column(
                  children: [
                    for (final pending in pendingExercises.take(3)) ...[
                      _ParentPendingTaskListItem(
                        pending: pending,
                      ),
                      if (pending != pendingExercises.take(3).last ||
                          expiredExercises.isNotEmpty)
                        const Divider(
                          height: 24,
                          indent: 62,
                          color: Color(0xFFE9EEF2),
                        ),
                    ],
                    for (final expired in expiredExercises.take(3)) ...[
                      _ParentPendingTaskListItem(
                        pending: expired,
                        isExpired: true,
                        onTap: () => _showExpiredExerciseMessage(context),
                      ),
                      if (expired != expiredExercises.take(3).last)
                        const Divider(
                          height: 24,
                          indent: 62,
                          color: Color(0xFFE9EEF2),
                        ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 14),
        _ParentRoomListSection(
          title: context.getText(AppKeys.assessmentResultTitle),
          onViewAll: widget.args.onOpenClassroomTab,
          child: completions.isEmpty
              ? _ParentEmptyTaskLine(
                  icon: Icons.fact_check_outlined,
                  text: context.getText(AppKeys.noCompletedHomeworkTitle),
                )
              : Column(
                  children: [
                    for (final completion in completions.take(5)) ...[
                      _ParentCompletedTaskListItem(
                        completion: completion,
                        onTap: () => _openCompletionResult(completion),
                      ),
                      if (completion != completions.take(5).last)
                        const Divider(
                          height: 24,
                          indent: 62,
                          color: Color(0xFFE9EEF2),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  void _openCompletionResult(HomeLayoutRecentCompletion completion) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudentHomeworkResultScreen(
          summary: _homeworkSummaryFromCompletion(context, completion),
        ),
      ),
    );
  }

  void _openRoomDetail(_ParentRoomEntry entry) {
    HapticFeedback.selectionClick();
    final parent = _layout?.parent;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _ParentRoomDetailScreen(
          entry: entry,
          pendingExercises: _pendingForRoomEntry(parent, entry),
          expiredExercises: _expiredForRoomEntry(parent, entry),
          completions: _completionsForRoomEntry(parent, entry),
          exerciseService: widget.args.assignmentService,
          onRefreshLayout: _loadLayout,
        ),
      ),
    );
  }
}
