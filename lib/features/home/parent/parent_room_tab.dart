part of '../home_screen.dart';

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
      _loadLayout();
    }
  }

  Future<void> _loadLayout() async {
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
    } on HomeLayoutException catch (error) {
      if (!mounted) {
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
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage =
            context.readText(AppKeys.parentChildDashboardLoadFailed);
      });
    }
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
          _ParentRoomHeader(topInset: topInset, scale: scale),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF339395),
              onRefresh: _loadLayout,
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
        onTap: _loadLayout,
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
          title:
              'Nhiệm vụ(${pendingExercises.length + expiredExercises.length})',
          onViewAll: widget.args.onOpenClassroomTab,
          child: pendingExercises.isEmpty && expiredExercises.isEmpty
              ? _ParentRoomEmptyLine(
                  icon: Icons.assignment_turned_in_outlined,
                  text: context.getText(AppKeys.studentNoHomeworkTitle),
                )
              : Column(
                  children: [
                    for (final pending in pendingExercises.take(3)) ...[
                      _ParentRoomPendingListItem(
                        pending: pending,
                        onTap: () => _openPendingExercise(pending),
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
                      _ParentRoomPendingListItem(
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
          title: 'Kết quả',
          onViewAll: widget.args.onOpenClassroomTab,
          child: completions.isEmpty
              ? _ParentRoomEmptyLine(
                  icon: Icons.fact_check_outlined,
                  text: context.getText(AppKeys.noCompletedHomeworkTitle),
                )
              : Column(
                  children: [
                    for (final completion in completions.take(5)) ...[
                      _ParentRoomCompletionListItem(
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

  Future<void> _openPendingExercise(HomeLayoutPendingExercise pending) async {
    final exercise = pending.exercise;
    final exerciseId = pending.classroomExerciseId ?? exercise?.stableId;
    final profileId = _layoutChildId(pending.child);
    if (exerciseId == null ||
        exerciseId <= 0 ||
        profileId == null ||
        profileId <= 0) {
      return;
    }

    HapticFeedback.selectionClick();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => StudentHomeworkAttemptScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
          exerciseService: widget.args.assignmentService,
        ),
      ),
    );
    if (mounted) {
      await _loadLayout();
    }
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

class _ParentRoomDetailScreen extends StatelessWidget {
  const _ParentRoomDetailScreen({
    required this.entry,
    required this.pendingExercises,
    required this.expiredExercises,
    required this.completions,
    required this.exerciseService,
    required this.onRefreshLayout,
  });

  final _ParentRoomEntry entry;
  final List<HomeLayoutPendingExercise> pendingExercises;
  final List<HomeLayoutPendingExercise> expiredExercises;
  final List<HomeLayoutRecentCompletion> completions;
  final ClassroomExerciseService exerciseService;
  final Future<void> Function() onRefreshLayout;

  @override
  Widget build(BuildContext context) {
    final title = _roomClassName(context, entry.classroom);
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ParentRoomDetailTopBar(
              title: title,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  14,
                  18,
                  14,
                  MediaQuery.paddingOf(context).bottom + 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ParentRoomDetailHero(entry: entry),
                    const SizedBox(height: 18),
                    _ParentRoomDetailShortcuts(
                      pendingCount:
                          pendingExercises.length + expiredExercises.length,
                      completedCount: completions.length,
                    ),
                    const SizedBox(height: 26),
                    _ParentRoomListSection(
                      title:
                          'Nhiệm vụ(${pendingExercises.length + expiredExercises.length})',
                      onViewAll: () => _parentRoomShowComingSoon(context),
                      child: pendingExercises.isEmpty &&
                              expiredExercises.isEmpty
                          ? _ParentRoomEmptyLine(
                              icon: Icons.assignment_turned_in_outlined,
                              text: context.getText(
                                AppKeys.studentNoHomeworkTitle,
                              ),
                            )
                          : Column(
                              children: [
                                for (final pending in pendingExercises) ...[
                                  _ParentRoomPendingListItem(
                                    pending: pending,
                                    onTap: () => _openPendingExercise(
                                      context,
                                      pending,
                                    ),
                                  ),
                                  if (pending != pendingExercises.last ||
                                      expiredExercises.isNotEmpty)
                                    const Divider(
                                      height: 24,
                                      indent: 62,
                                      color: Color(0xFFE9EEF2),
                                    ),
                                ],
                                for (final expired in expiredExercises) ...[
                                  _ParentRoomPendingListItem(
                                    pending: expired,
                                    isExpired: true,
                                    onTap: () =>
                                        _showExpiredExerciseMessage(context),
                                  ),
                                  if (expired != expiredExercises.last)
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
                      title: 'Kết quả',
                      onViewAll: () => _parentRoomShowComingSoon(context),
                      child: completions.isEmpty
                          ? _ParentRoomEmptyLine(
                              icon: Icons.fact_check_outlined,
                              text: context.getText(
                                AppKeys.noCompletedHomeworkTitle,
                              ),
                            )
                          : Column(
                              children: [
                                for (final completion in completions) ...[
                                  _ParentRoomCompletionListItem(
                                    completion: completion,
                                    onTap: () => _openCompletionResult(
                                      context,
                                      completion,
                                    ),
                                  ),
                                  if (completion != completions.last)
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPendingExercise(
    BuildContext context,
    HomeLayoutPendingExercise pending,
  ) async {
    final exercise = pending.exercise;
    final exerciseId = pending.classroomExerciseId ?? exercise?.stableId;
    final profileId = _layoutChildId(pending.child) ?? entry.memberProfileId;
    if (exerciseId == null ||
        exerciseId <= 0 ||
        profileId == null ||
        profileId <= 0) {
      return;
    }

    HapticFeedback.selectionClick();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => StudentHomeworkAttemptScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
          exerciseService: exerciseService,
        ),
      ),
    );
    await onRefreshLayout();
  }

  void _openCompletionResult(
    BuildContext context,
    HomeLayoutRecentCompletion completion,
  ) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudentHomeworkResultScreen(
          summary: _homeworkSummaryFromCompletion(context, completion),
        ),
      ),
    );
  }
}

class _ParentRoomHeader extends StatelessWidget {
  const _ParentRoomHeader({
    required this.topInset,
    required this.scale,
  });

  final double topInset;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: topInset + 60 * scale,
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF2F2F2),
            width: 4 * scale,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        context.getText(AppKeys.navRoom),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: const Color(0xFF339395),
          fontSize: FontSize.title,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ParentRoomClassGrid extends StatelessWidget {
  const _ParentRoomClassGrid({
    required this.entries,
    required this.onTap,
  });

  final List<_ParentRoomEntry> entries;
  final ValueChanged<_ParentRoomEntry> onTap;

  @override
  Widget build(BuildContext context) {
    if (entries.length == 1) {
      final entry = entries.first;
      return SizedBox(
        width: double.infinity,
        height: 101,
        child: _ParentRoomClassCard(
          entry: entry,
          index: 0,
          onTap: () => onTap(entry),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 12,
        mainAxisExtent: 101,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _ParentRoomClassCard(
          entry: entry,
          index: index,
          onTap: () => onTap(entry),
        );
      },
    );
  }
}

class _ParentRoomClassCard extends StatelessWidget {
  const _ParentRoomClassCard({
    required this.entry,
    required this.index,
    required this.onTap,
  });

  final _ParentRoomEntry entry;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBlue = index.isOdd;
    final childName = homeProfileDisplayName(context, entry.child);
    final className = _roomClassName(context, entry.classroom);
    final teacherName = _roomTeacherName(context, entry);
    final fg = isBlue ? const Color(0xFF006CB6) : const Color(0xFF276C6B);
    final bg = isBlue ? const Color(0xFFEAF3FA) : const Color(0xFFE7F6F5);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBlue ? const Color(0xFFD1DFE9) : const Color(0xFFCBE6E4),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                childName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                className,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                teacherName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _ParentRoomSectionTitle extends StatelessWidget {
  const _ParentRoomSectionTitle({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3265E6),
            size: 18,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF202328),
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParentRoomListSection extends StatelessWidget {
  const _ParentRoomListSection({
    required this.title,
    required this.child,
    required this.onViewAll,
  });

  final String title;
  final Widget child;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0F3F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1B3D91),
                          fontSize: FontSize.large,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2775FF),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                label: Text(
                  context.getText(AppKeys.viewAll),
                  style: const TextStyle(
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                icon: const Icon(Icons.chevron_right_rounded, size: 18),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ParentRoomPendingListItem extends StatelessWidget {
  const _ParentRoomPendingListItem({
    required this.pending,
    required this.onTap,
    this.isExpired = false,
  });

  final HomeLayoutPendingExercise pending;
  final VoidCallback onTap;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final exercise = pending.exercise;
    final title = _roomExerciseTitle(context, exercise);
    final childName = pending.child == null
        ? null
        : homeProfileDisplayName(context, pending.child!);
    final classroomName = _roomClassName(context, pending.classroom);
    final accent = isExpired
        ? (
            color: const Color(0xFFFF7A1A),
            background: const Color(0xFFFFF0D8),
            icon: Icons.warning_amber_rounded,
            asset: null,
          )
        : _roomPurposeListAccent(exercise?.purpose);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            _ParentRoomListIconBox(
              icon: accent.icon,
              asset: accent.asset,
              color: accent.color,
              backgroundColor: accent.background,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _ParentRoomBadgeRow(
                          childName: childName,
                          classroomName: classroomName,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ParentRoomListDateLabel(
                        date: _roomDateOnlyLabel(
                          exercise?.endDate ?? exercise?.createDt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _ParentRoomListTitle(title: title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentRoomCompletionListItem extends StatelessWidget {
  const _ParentRoomCompletionListItem({
    required this.completion,
    required this.onTap,
  });

  final HomeLayoutRecentCompletion completion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exercise = completion.exercise;
    final score = ((completion.scorePercentage ?? 0) / 10).round().clamp(0, 10);
    final color =
        score >= 8 ? const Color(0xFF07824C) : const Color(0xFFFF6B17);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            _ParentRoomScoreIcon(score: score, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _ParentRoomBadgeRow(
                          childName: completion.child == null
                              ? null
                              : homeProfileDisplayName(
                                  context,
                                  completion.child!,
                                ),
                          classroomName:
                              _roomClassName(context, completion.classroom),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ParentRoomListDateLabel(
                        date: _roomDateOnlyLabel(
                          completion.gradedDt ??
                              completion.submittedDt ??
                              completion.exercise?.createDt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _ParentRoomListTitle(
                    title: _roomExerciseTitle(context, exercise),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentRoomBadgeRow extends StatelessWidget {
  const _ParentRoomBadgeRow({
    required this.childName,
    required this.classroomName,
  });

  final String? childName;
  final String classroomName;

  @override
  Widget build(BuildContext context) {
    final cleanChildName = childName?.trim();
    final cleanClassroom = classroomName.trim();

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: [
        if (cleanChildName?.isNotEmpty == true)
          _ParentRoomChip(
              label: cleanChildName!,
              color: const Color(0xFFEAF7F7),
              textColor: const Color(0xFF7F8FA0),
              fontSize: FontSize.xsmall),
        if (cleanClassroom.isNotEmpty)
          _ParentRoomChip(
              label: cleanClassroom,
              color: const Color(0xFFEAF7F7),
              textColor: const Color(0xFF7F8FA0),
              fontSize: FontSize.xsmall),
      ],
    );
  }
}

class _ParentRoomListTitle extends StatelessWidget {
  const _ParentRoomListTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
    );
  }
}

class _ParentRoomListDateLabel extends StatelessWidget {
  const _ParentRoomListDateLabel({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.alarm_rounded,
          color: Colors.black87,
          size: FontSize.xsmall,
        ),
        const SizedBox(width: 4),
        Text(
          date,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: FontSize.xsmall,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ParentRoomListIconBox extends StatelessWidget {
  const _ParentRoomListIconBox({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.asset,
  });

  final IconData icon;
  final String? asset;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
      ),
      child: asset == null
          ? Icon(icon, color: color, size: 24)
          : Center(
              child: SvgPicture.asset(
                asset!,
                width: 25,
                height: 25,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
    );
  }
}

class _ParentRoomEmptyLine extends StatelessWidget {
  const _ParentRoomEmptyLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ParentRoomListIconBox(
          icon: icon,
          color: const Color(0xFF339395),
          backgroundColor: const Color(0xFFEAF3F3),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6D778A),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _ParentRoomPendingCard extends StatelessWidget {
  const _ParentRoomPendingCard({
    required this.pending,
    required this.onTap,
    // ignore: unused_element_parameter
    this.compact = false,
    // ignore: unused_element_parameter
    this.isExpired = false,
  });

  final HomeLayoutPendingExercise pending;
  final VoidCallback onTap;
  final bool compact;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final exercise = pending.exercise;
    final title = _roomExerciseTitle(context, exercise);
    final childName = pending.child == null
        ? null
        : homeProfileDisplayName(context, pending.child!);
    final classroomName = _roomClassName(context, pending.classroom);
    final dateLabel = _roomExerciseCreatedDate(exercise);
    final dueLabel = _roomExerciseDueLabel(context, exercise);
    final purpose = _roomPurposeLabel(context, exercise?.purpose);
    final dueSoon = _roomExerciseDueSoon(exercise);
    final accent = isExpired
        ? (color: const Color(0xFFB91C1C), badge: const Color(0xFFFFE2E2))
        : dueSoon
            ? (color: const Color(0xFFFF7A1A), badge: const Color(0xFFFFF0D8))
            : _roomPurposeAccent(exercise?.purpose);
    final statusLabel = isExpired
        ? context.getText(AppKeys.homeworkFailed)
        : dueSoon
            ? context.getText(AppKeys.homeworkDueSoon)
            : purpose;

    return _ParentRoomTaskShell(
      accent: accent.color,
      compact: compact,
      onTap: onTap,
      leading: _ParentRoomStatusIcon(
        icon: isExpired
            ? Icons.warning_amber_rounded
            : dueSoon
                ? Icons.notification_important_outlined
                : Icons.assignment_outlined,
        color: accent.color,
        backgroundColor: accent.badge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ParentRoomTaskHeader(
            dateLabel: dateLabel,
            childName: childName,
            classroomName: classroomName,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF121B42),
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ),
              _ParentRoomChip(
                label: statusLabel,
                color: accent.badge,
                textColor: accent.color,
                fontSize: FontSize.xsmall,
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Divider(height: 1, color: Color(0xFFE7E4E4)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Color(0xFF5D5D5D),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  dueLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5D5D5D),
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _ParentRoomCompletionCard extends StatelessWidget {
  const _ParentRoomCompletionCard({
    required this.completion,
    required this.onTap,
    // ignore: unused_element_parameter
    this.compact = false,
  });

  final HomeLayoutRecentCompletion completion;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final exercise = completion.exercise;
    final title = _roomExerciseTitle(context, exercise);
    final childName = completion.child == null
        ? null
        : homeProfileDisplayName(context, completion.child!);
    final classroomName = _roomClassName(context, completion.classroom);
    final purpose = _roomPurposeLabel(context, exercise?.purpose);
    final accent = _roomScoreAccent(completion.scorePercentage);
    final dateLabel = _roomDateLabel(
      completion.gradedDt ?? completion.submittedDt ?? exercise?.createDt,
    );
    final score = ((completion.scorePercentage ?? 0) / 10).round().clamp(0, 10);

    return _ParentRoomTaskShell(
      accent: accent,
      compact: compact,
      onTap: onTap,
      leading: _ParentRoomScoreIcon(score: score, color: accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ParentRoomTaskHeader(
            dateLabel: dateLabel,
            childName: childName,
            classroomName: classroomName,
          ),
          const SizedBox(height: 9),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF121B42),
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 7),
          _ParentRoomChip(
            label: purpose,
            color: accent.withValues(alpha: 0.13),
            textColor: accent,
            fontSize: FontSize.xsmall,
          ),
        ],
      ),
    );
  }
}

class _ParentRoomStatusIcon extends StatelessWidget {
  const _ParentRoomStatusIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _ParentRoomScoreIcon extends StatelessWidget {
  const _ParentRoomScoreIcon({
    required this.score,
    required this.color,
  });

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score <= 0 ? 0 : (score / 10).clamp(0.08, 1),
            strokeWidth: 5,
            backgroundColor: color.withValues(alpha: 0.12),
            color: color,
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Text(
              '$score',
              style: TextStyle(
                color: color,
                fontSize: FontSize.title,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentRoomTaskShell extends StatelessWidget {
  const _ParentRoomTaskShell({
    required this.accent,
    required this.child,
    required this.onTap,
    required this.compact,
    this.leading,
  });

  final Color accent;
  final Widget child;
  final Widget? leading;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: compact ? 2.5 : 1.5,
      shadowColor: Colors.black.withValues(alpha: compact ? 0.16 : 0.10),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 101 : 103),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 13),
                    ],
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentRoomTaskHeader extends StatelessWidget {
  const _ParentRoomTaskHeader({
    required this.dateLabel,
    required this.childName,
    required this.classroomName,
  });

  final String dateLabel;
  final String? childName;
  final String classroomName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            dateLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B5C62),
              fontSize: FontSize.date,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (childName != null)
          _ParentRoomChip(
            label: childName!,
            color: const Color(0xFFF2F4F6),
            textColor: const Color(0xFF4F5960),
            fontSize: FontSize.xsmall,
          ),
        const SizedBox(width: 5),
        _ParentRoomChip(
          label: classroomName,
          color: const Color(0xFFF2F4F6),
          textColor: const Color(0xFF4F5960),
          fontSize: FontSize.xsmall,
        ),
      ],
    );
  }
}

class _ParentRoomChip extends StatelessWidget {
  const _ParentRoomChip({
    required this.fontSize,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 82),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: FontSize.xsmall,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ParentRoomDetailTopBar extends StatelessWidget {
  const _ParentRoomDetailTopBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF339395),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.andika(
                color: const Color(0xFF339395),
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 34 / 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentRoomDetailHero extends StatelessWidget {
  const _ParentRoomDetailHero({required this.entry});

  final _ParentRoomEntry entry;

  @override
  Widget build(BuildContext context) {
    final className = _roomClassName(context, entry.classroom);
    final teacherName = _roomTeacherName(context, entry);
    final grade = entry.classroom.gradeId == null
        ? context.getText(AppKeys.teacherAssignmentClassGrade)
        : '${context.getText(AppKeys.teacherAssignmentClassGrade)} ${entry.classroom.gradeId}';
    final description = entry.classroom.description?.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E8EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFFFF5C9E),
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF121B42),
                    fontSize: FontSize.title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _parentRoomShowComingSoon(context),
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _ParentRoomDetailMeta(icon: Icons.groups_2_outlined, label: grade),
          const SizedBox(height: 7),
          _ParentRoomDetailMeta(
            icon: Icons.workspace_premium_outlined,
            label: teacherName,
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 7),
            _ParentRoomDetailMeta(
              icon: Icons.notes_rounded,
              label: description,
            ),
          ],
        ],
      ),
    );
  }
}

class _ParentRoomDetailMeta extends StatelessWidget {
  const _ParentRoomDetailMeta({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4B5563)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF121B42),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParentRoomDetailShortcuts extends StatelessWidget {
  const _ParentRoomDetailShortcuts({
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      padding: EdgeInsets.zero,
      children: [
        _ParentRoomShortcutTile(
          icon: Icons.assignment_outlined,
          iconColor: const Color(0xFF0A2B67),
          iconBg: const Color(0xFFEAF1FF),
          title: context.getText(AppKeys.studentClassAssignments),
          subtitle: context.formatText(
            AppKeys.studentClassAssignmentsCountFormat,
            {'count': pendingCount},
          ),
        ),
        _ParentRoomShortcutTile(
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFFF6B4A),
          iconBg: const Color(0xFFFFEFE8),
          title: context.getText(AppKeys.studentClassGrades),
          subtitle: completedCount == 0
              ? context.getText(AppKeys.incomplete)
              : context.getText(AppKeys.completedResultTitle),
        ),
        _ParentRoomShortcutTile(
          icon: Icons.campaign_outlined,
          iconColor: const Color(0xFF3265E6),
          iconBg: const Color(0xFFEAF1FF),
          title: context.getText(AppKeys.navMembers),
          subtitle: context.getText(AppKeys.studentClassComingSoon),
        ),
        _ParentRoomShortcutTile(
          icon: Icons.folder_outlined,
          iconColor: const Color(0xFFFF7A1A),
          iconBg: const Color(0xFFFFF0D8),
          title: context.getText(AppKeys.studentClassMaterials),
          subtitle: context.getText(AppKeys.studentClassMaterialsSubtitle),
        ),
      ],
    );
  }
}

class _ParentRoomShortcutTile extends StatelessWidget {
  const _ParentRoomShortcutTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF121B42),
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentRoomLoading extends StatefulWidget {
  const _ParentRoomLoading({super.key});

  @override
  State<_ParentRoomLoading> createState() => _ParentRoomLoadingState();
}

class _ParentRoomLoadingState extends State<_ParentRoomLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return _ParentSkeletonShimmer(
          progress: _controller.value,
          child: const _ParentRoomLoadingContent(),
        );
      },
    );
  }
}

class _ParentRoomLoadingContent extends StatelessWidget {
  const _ParentRoomLoadingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.55,
          padding: EdgeInsets.zero,
          children: const [
            _ParentRoomSkeletonBlock(),
            _ParentRoomSkeletonBlock(),
          ],
        ),
        const SizedBox(height: 24),
        const _ParentRoomSkeletonLine(width: 128),
        const SizedBox(height: 14),
        const _ParentRoomSkeletonBlock(height: 104),
        const SizedBox(height: 14),
        const _ParentRoomSkeletonBlock(height: 104),
        const SizedBox(height: 14),
        const _ParentRoomSkeletonLine(width: 92),
        const SizedBox(height: 14),
        const _ParentRoomSkeletonBlock(height: 104),
      ],
    );
  }
}

class _ParentRoomSkeletonBlock extends StatelessWidget {
  const _ParentRoomSkeletonBlock({this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5EFEE),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _ParentRoomSkeletonLine extends StatelessWidget {
  const _ParentRoomSkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFFE5EFEE),
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _ParentRoomEmptyBox extends StatelessWidget {
  const _ParentRoomEmptyBox({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E8EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF339395), size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF121B42),
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentRoomStateCard extends StatelessWidget {
  const _ParentRoomStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1E8E7)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF339395), size: 48),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF17252B),
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF77859A),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onTap,
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}

class _ParentRoomEntry {
  const _ParentRoomEntry({
    required this.layoutClassroom,
    required this.child,
  });

  final HomeLayoutClassroom layoutClassroom;
  final StudentProfile child;

  ClassroomModel get classroom => layoutClassroom.classroom;

  int? get classroomId => classroom.stableId;

  int? get memberProfileId =>
      layoutClassroom.memberProfileId ??
      ActiveProfileSession.profileStableId(child);
}

List<_ParentRoomEntry> _roomEntries(ParentHomeLayout? parent) {
  if (parent == null) {
    return const <_ParentRoomEntry>[];
  }

  final childById = <int, StudentProfile>{
    for (final child in parent.children)
      if (ActiveProfileSession.profileStableId(child) != null)
        ActiveProfileSession.profileStableId(child)!: child,
  };

  final layoutClassroomById = <int, HomeLayoutClassroom>{
    for (final layoutClassroom in parent.classrooms)
      if (layoutClassroom.classroom.stableId != null)
        layoutClassroom.classroom.stableId!: layoutClassroom,
  };
  final entries = <_ParentRoomEntry>[];
  final entryKeys = <String>{};

  void addEntry({
    required HomeLayoutClassroom layoutClassroom,
    required StudentProfile child,
    int? memberProfileId,
  }) {
    final classroomId = layoutClassroom.classroom.stableId;
    final childId =
        memberProfileId ?? ActiveProfileSession.profileStableId(child);
    if (classroomId == null || childId == null) {
      return;
    }
    final key = '$classroomId:$childId';
    if (!entryKeys.add(key)) {
      return;
    }
    entries.add(
      _ParentRoomEntry(layoutClassroom: layoutClassroom, child: child),
    );
  }

  for (final layoutClassroom in parent.classrooms) {
    final memberProfileId = layoutClassroom.memberProfileId;
    final child = memberProfileId == null ? null : childById[memberProfileId];
    if (child != null) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: child,
        memberProfileId: memberProfileId,
      );
    } else if (parent.children.length == 1) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: parent.children.first,
        memberProfileId: memberProfileId,
      );
    }
  }

  for (final pending in parent.pendingExercises) {
    final childId = _layoutChildId(pending.child);
    final classroomId = pending.classroomId ?? pending.exercise?.classroomId;
    final child = childId == null ? null : childById[childId] ?? pending.child;
    if (child == null || classroomId == null) {
      continue;
    }
    final layoutClassroom = _layoutClassroomForChildClass(
      parent: parent,
      layoutClassroomById: layoutClassroomById,
      classroomId: classroomId,
      childId: childId!,
      fallbackClassroom: pending.classroom,
    );
    if (layoutClassroom != null) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: child,
        memberProfileId: childId,
      );
    }
  }

  for (final expired in parent.expiredExercises) {
    final childId = _layoutChildId(expired.child);
    final classroomId = expired.classroomId ?? expired.exercise?.classroomId;
    final child = childId == null ? null : childById[childId] ?? expired.child;
    if (child == null || classroomId == null) {
      continue;
    }
    final layoutClassroom = _layoutClassroomForChildClass(
      parent: parent,
      layoutClassroomById: layoutClassroomById,
      classroomId: classroomId,
      childId: childId!,
      fallbackClassroom: expired.classroom,
    );
    if (layoutClassroom != null) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: child,
        memberProfileId: childId,
      );
    }
  }

  for (final completion in parent.recentCompletions) {
    final childId = _layoutChildId(completion.child);
    final classroomId =
        completion.classroomId ?? completion.exercise?.classroomId;
    final child =
        childId == null ? null : childById[childId] ?? completion.child;
    if (child == null || classroomId == null) {
      continue;
    }
    final layoutClassroom = _layoutClassroomForChildClass(
      parent: parent,
      layoutClassroomById: layoutClassroomById,
      classroomId: classroomId,
      childId: childId!,
      fallbackClassroom: completion.classroom,
    );
    if (layoutClassroom != null) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: child,
        memberProfileId: childId,
      );
    }
  }

  return entries;
}

HomeLayoutClassroom? _layoutClassroomForChildClass({
  required ParentHomeLayout parent,
  required Map<int, HomeLayoutClassroom> layoutClassroomById,
  required int classroomId,
  required int childId,
  required ClassroomModel? fallbackClassroom,
}) {
  for (final layoutClassroom in parent.classrooms) {
    if (layoutClassroom.classroom.stableId == classroomId &&
        layoutClassroom.memberProfileId == childId) {
      return layoutClassroom;
    }
  }

  final sharedClassroom = layoutClassroomById[classroomId];
  if (sharedClassroom != null) {
    return HomeLayoutClassroom(
      classroom: sharedClassroom.classroom,
      memberProfileId: childId,
      myRole: sharedClassroom.myRole,
    );
  }

  if (fallbackClassroom != null) {
    return HomeLayoutClassroom(
      classroom: fallbackClassroom,
      memberProfileId: childId,
    );
  }

  return null;
}

List<HomeLayoutPendingExercise> _pendingForRoomEntry(
  ParentHomeLayout? parent,
  _ParentRoomEntry entry,
) {
  if (parent == null) {
    return const <HomeLayoutPendingExercise>[];
  }
  return parent.pendingExercises.where((pending) {
    return _sameRoom(
      classroomId: pending.classroomId ?? pending.exercise?.classroomId,
      childId: _layoutChildId(pending.child),
      entry: entry,
    );
  }).toList(growable: false);
}

List<HomeLayoutPendingExercise> _expiredForRoomEntry(
  ParentHomeLayout? parent,
  _ParentRoomEntry entry,
) {
  if (parent == null) {
    return const <HomeLayoutPendingExercise>[];
  }
  return parent.expiredExercises.where((expired) {
    return _sameRoom(
      classroomId: expired.classroomId ?? expired.exercise?.classroomId,
      childId: _layoutChildId(expired.child),
      entry: entry,
    );
  }).toList(growable: false);
}

List<HomeLayoutRecentCompletion> _completionsForRoomEntry(
  ParentHomeLayout? parent,
  _ParentRoomEntry entry,
) {
  if (parent == null) {
    return const <HomeLayoutRecentCompletion>[];
  }
  return parent.recentCompletions.where((completion) {
    return _sameRoom(
      classroomId: completion.classroomId ?? completion.exercise?.classroomId,
      childId: _layoutChildId(completion.child),
      entry: entry,
    );
  }).toList(growable: false);
}

bool _sameRoom({
  required int? classroomId,
  required int? childId,
  required _ParentRoomEntry entry,
}) {
  return classroomId != null &&
      classroomId == entry.classroomId &&
      childId != null &&
      childId == entry.memberProfileId;
}

String _roomClassName(BuildContext context, ClassroomModel? classroom) {
  final name = classroom?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  return context.getText(AppKeys.teacherClassFallback);
}

String _roomTeacherName(BuildContext context, _ParentRoomEntry entry) {
  final values = <String?>[
    entry.classroom.teacherName,
    entry.classroom.owner?.name,
  ];
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return context.getText(AppKeys.teacherFallback);
}

String _roomExerciseTitle(BuildContext context, ClassroomExercise? exercise) {
  final title = exercise?.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  return context.getText(AppKeys.studentHomework);
}

String _roomPurposeLabel(BuildContext context, String? purpose) {
  final normalized = purpose?.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return context.getText(AppKeys.test);
  }
  return context.getText(AppKeys.studentHomework);
}

({Color color, Color badge}) _roomPurposeAccent(String? purpose) {
  final normalized = purpose?.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return (color: const Color(0xFFBD1C21), badge: const Color(0xFFFFDDE6));
  }
  return (color: const Color(0xFF147A8F), badge: const Color(0xFFDDF4F8));
}

({Color color, Color background, IconData icon, String? asset})
    _roomPurposeListAccent(String? purpose) {
  final normalized = purpose?.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return (
      color: const Color(0xFFBD1C21),
      background: const Color(0xFFFFEFF1),
      icon: Icons.analytics_outlined,
      asset: 'assets/images/parent_room_assessment.svg',
    );
  }
  return (
    color: const Color(0xFF147A8F),
    background: const Color(0xFFEAF6FF),
    icon: Icons.menu_book_outlined,
    asset: null,
  );
}

Color _roomScoreAccent(int? scorePercentage) {
  final score = ((scorePercentage ?? 0) / 10).round();
  if (score >= 8) {
    return const Color(0xFF087D47);
  }
  return const Color(0xFFFF6B17);
}

String _roomExerciseCreatedDate(ClassroomExercise? exercise) {
  return _roomDateLabel(exercise?.createDt ?? exercise?.startDate);
}

String _roomExerciseDueLabel(
    BuildContext context, ClassroomExercise? exercise) {
  final date = _roomDateLabel(exercise?.endDate);
  if (date == '--/--/----') {
    return context.getText(AppKeys.teacherAssignmentDueLabel);
  }
  return context.formatText(AppKeys.studentHomeworkDueFormat, {'date': date});
}

String _roomDateOnlyLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '')?.toLocal();
  if (parsed == null) {
    return '--/--/----';
  }
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}';
}

bool _roomExerciseDueSoon(ClassroomExercise? exercise) {
  final endDate = DateTime.tryParse(exercise?.endDate?.trim() ?? '')?.toLocal();
  if (endDate == null) {
    return false;
  }
  final remaining = endDate.difference(DateTime.now());
  return !remaining.isNegative && remaining <= const Duration(days: 2);
}

String _roomDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '')?.toLocal();
  if (parsed == null) {
    return '--/--/----';
  }
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)} '
      '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}';
}

void _showExpiredExerciseMessage(BuildContext context) {
  HapticFeedback.selectionClick();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.homeworkExpiredCannotSubmit)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
      ),
    );
}

void _parentRoomShowComingSoon(BuildContext context) {
  HapticFeedback.selectionClick();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.studentClassComingSoon)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
}
