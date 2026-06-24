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
        const SizedBox(height: 24),
        for (final pending in pendingExercises.take(3)) ...[
          _ParentRoomPendingCard(
            pending: pending,
            onTap: () => _openPendingExercise(pending),
          ),
          const SizedBox(height: 14),
        ],
        for (final expired in expiredExercises.take(3)) ...[
          _ParentRoomPendingCard(
            pending: expired,
            isExpired: true,
            onTap: () => _openPendingExercise(expired),
          ),
          const SizedBox(height: 14),
        ],
        if (completions.isNotEmpty) ...[
          const SizedBox(height: 4),
          _ParentRoomSectionTitle(
            icon: Icons.inventory_2_rounded,
            label: context.getText(AppKeys.assessmentResultTitle),
          ),
          const SizedBox(height: 14),
          for (final completion in completions.take(5)) ...[
            _ParentRoomCompletionCard(
              completion: completion,
              onTap: () => _openCompletionResult(completion),
            ),
            const SizedBox(height: 14),
          ],
        ],
        if (_isLoading && _hasLoaded)
          Text(
            context.getText(AppKeys.loading),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6D5C5C),
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w700,
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
    final childName = homeProfileDisplayName(context, entry.child);

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
                    for (final pending in pendingExercises) ...[
                      _ParentRoomPendingCard(
                        pending: pending,
                        compact: true,
                        onTap: () => _openPendingExercise(context, pending),
                      ),
                      const SizedBox(height: 14),
                    ],
                    for (final expired in expiredExercises) ...[
                      _ParentRoomPendingCard(
                        pending: expired,
                        compact: true,
                        isExpired: true,
                        onTap: () => _openPendingExercise(context, expired),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (completions.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _ParentRoomSectionTitle(
                        icon: Icons.inventory_2_rounded,
                        label: context.getText(AppKeys.assessmentResultTitle),
                      ),
                      const SizedBox(height: 14),
                      for (final completion in completions) ...[
                        _ParentRoomCompletionCard(
                          completion: completion,
                          compact: true,
                          onTap: () => _openCompletionResult(
                            context,
                            completion,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],
                    if (pendingExercises.isEmpty &&
                        expiredExercises.isEmpty &&
                        completions.isEmpty)
                      _ParentRoomStateCard(
                        icon: Icons.assignment_outlined,
                        title: context.getText(AppKeys.studentNoHomeworkTitle),
                        message: context.getText(
                          AppKeys.studentNoHomeworkMessage,
                        ),
                        onTap: onRefreshLayout,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      childName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8A979B),
                        fontSize: FontSize.caption,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _ParentRoomPendingCard extends StatelessWidget {
  const _ParentRoomPendingCard({
    required this.pending,
    required this.onTap,
    this.compact = false,
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
    final accent = isExpired
        ? (color: const Color(0xFFC2410C), badge: const Color(0xFFFFE7D6))
        : _roomPurposeAccent(exercise?.purpose);
    final statusLabel =
        isExpired ? context.getText(AppKeys.studentHomeworkOverdue) : purpose;

    return _ParentRoomTaskShell(
      accent: accent.color,
      compact: compact,
      onTap: onTap,
      leading: null,
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

class _ParentRoomCompletionCard extends StatelessWidget {
  const _ParentRoomCompletionCard({
    required this.completion,
    required this.onTap,
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
      leading: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: (completion.scorePercentage ?? 0).clamp(0, 100) / 100,
              strokeWidth: 5,
              backgroundColor: accent.withValues(alpha: 0.12),
              color: accent,
              strokeCap: StrokeCap.round,
            ),
            Center(
              child: Text(
                '$score',
                style: TextStyle(
                  color: accent,
                  fontSize: FontSize.title,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
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
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 101 : 103),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 13,
                offset: const Offset(5, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(width: 4, color: accent),
              if (leading != null) ...[
                const SizedBox(width: 14),
                leading!,
                const SizedBox(width: 13),
              ] else
                const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: child,
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
              fontSize: FontSize.caption * 0.82,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (childName != null)
          _ParentRoomChip(
            label: childName!,
            color: const Color(0xFFF2F4F6),
            textColor: const Color(0xFF4F5960),
          ),
        const SizedBox(width: 5),
        _ParentRoomChip(
          label: classroomName,
          color: const Color(0xFFF2F4F6),
          textColor: const Color(0xFF4F5960),
        ),
      ],
    );
  }
}

class _ParentRoomChip extends StatelessWidget {
  const _ParentRoomChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

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
          fontSize: FontSize.caption * 0.68,
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

class _ParentRoomLoading extends StatelessWidget {
  const _ParentRoomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const _ParentRoomSkeletonBlock(height: 104),
        const SizedBox(height: 14),
        const _ParentRoomSkeletonBlock(height: 104),
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

String _roomDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '')?.toLocal();
  if (parsed == null) {
    return '--/--/----';
  }
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)} '
      '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}';
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
