part of '../../home_screen.dart';

class ParentAssessmentTab extends StatefulWidget {
  const ParentAssessmentTab({super.key, required this.args});

  final HomeDashboardArgs args;

  @override
  State<ParentAssessmentTab> createState() => _ParentAssessmentTabState();
}

class _ParentAssessmentTabState extends State<ParentAssessmentTab> {
  final TextEditingController _searchController = TextEditingController();

  List<_ParentAssessmentEntry> _entries = const <_ParentAssessmentEntry>[];
  bool _isLoading = true;
  bool _hasCompletedInitialLoad = false;
  bool _hasPlayedInitialEntrance = false;
  String? _errorMessage;
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    if (widget.args.isActive) {
      _loadAssessments();
    }
  }

  @override
  void didUpdateWidget(covariant ParentAssessmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.args.isActive && widget.args.isActive) {
      _loadAssessments(forceRefresh: true);
      return;
    }
    if (!widget.args.isActive) {
      return;
    }
    if (_profileSourceKey(oldWidget.args) != _profileSourceKey(widget.args)) {
      _loadAssessments();
    } else if (oldWidget.args.activeRefreshTick !=
        widget.args.activeRefreshTick) {
      _loadAssessments(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  String _profileSourceKey(HomeDashboardArgs args) {
    return '${args.user?.id}|'
        '${ActiveProfileSession.profileStableId(args.activeProfile)}';
  }

  Future<void> _loadAssessments({bool forceRefresh = false}) async {
    final requestId = ++_loadRequestId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.args.activeProfile,
    );
    final userId = widget.args.user?.id;
    final cache = HomeProfileCache.instance;
    final cachedSnapshot = profileId == null
        ? null
        : cache.getParent(profileId);
    if (!forceRefresh &&
        cachedSnapshot != null &&
        cachedSnapshot.completedAssessments.isNotEmpty) {
      setState(() => _applyCachedAssessments(cachedSnapshot));
      if (!cachedSnapshot.isStale) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final entries = <_ParentAssessmentEntry>[];
    var failed = false;

    if ((profileId != null && profileId > 0) ||
        (userId != null && userId > 0)) {
      try {
        final quizzes = await _loadCompletedParentAssessments(
          quizService: widget.args.quizService,
          profileId: profileId,
          userId: userId,
        );
        entries.addAll(
          quizzes.map((quiz) => _ParentAssessmentEntry(quiz: quiz)),
        );
      } catch (_) {
        failed = true;
      }
    }

    if (!mounted || requestId != _loadRequestId) {
      return;
    }

    entries.sort((a, b) => _quizDate(b.quiz).compareTo(_quizDate(a.quiz)));
    setState(() {
      if (!failed || entries.isNotEmpty || _entries.isEmpty) {
        _entries = entries;
      }
      _isLoading = false;
      _hasCompletedInitialLoad = true;
      _errorMessage = failed && _entries.isEmpty
          ? context.readText(AppKeys.parentQuizLoadFailed)
          : null;
    });
    if (!failed &&
        profileId != null &&
        profileId > 0 &&
        cachedSnapshot != null) {
      cache.putParent(
        ParentHomeSnapshot(
          profileId: profileId,
          homeLayout: cachedSnapshot.homeLayout,
          completedAssessments: entries
              .map((entry) => entry.quiz)
              .toList(growable: false),
          cachedAt: DateTime.now(),
        ),
      );
    }
  }

  void _applyCachedAssessments(ParentHomeSnapshot snapshot) {
    _entries =
        snapshot.completedAssessments
            .map((quiz) => _ParentAssessmentEntry(quiz: quiz))
            .toList(growable: false)
          ..sort((a, b) => _quizDate(b.quiz).compareTo(_quizDate(a.quiz)));
    _isLoading = false;
    _hasCompletedInitialLoad = true;
    _errorMessage = null;
  }

  List<_ParentAssessmentEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _entries;
    }
    return _entries
        .where((entry) {
          final searchable = <String>[
            _homeQuizTitle(context, entry.quiz),
            _homeQuizDateLabel(entry.quiz),
          ].join(' ').toLowerCase();
          return searchable.contains(query);
        })
        .toList(growable: false);
  }

  void _openQuizReview(GeneratedQuiz quiz) {
    final quizId = quiz.quizId ?? quiz.id;
    if (quizId == null || quizId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizReviewScreen(quizId: quizId, initialQuiz: quiz),
      ),
    );
  }

  Future<void> _openAssessment() async {
    HapticFeedback.lightImpact();
    final assessmentTabRoute = ModalRoute.of(context);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GradeSelectionScreen(
          user: widget.args.user,
          initialGrades: widget.args.initialGrades,
          gradeService: widget.args.gradeService,
          quizPurpose: quizPurposeAssessment,
          profileId: ActiveProfileSession.profileStableId(
            widget.args.activeProfile,
          ),
          initialGradeId: profileGradeId(widget.args.activeProfile),
          initialGradeLabel: widget.args.activeProfile?.grade?.label,
          onResultBack: () {
            if (!mounted) {
              return;
            }
            final navigator = Navigator.of(context);
            if (assessmentTabRoute == null) {
              navigator.popUntil((route) => route.isFirst);
              return;
            }
            navigator.popUntil((route) => identical(route, assessmentTabRoute));
          },
        ),
      ),
    );
    if (mounted) {
      await _loadAssessments(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.args.scale;
    final topInset = MediaQuery.paddingOf(context).top;
    final entries = _filteredEntries;
    final isInitialLoading = _isLoading && !_hasCompletedInitialLoad;

    return ColoredBox(
      color: const Color(0xFFF1FBFA),
      child: RefreshIndicator(
        color: const Color(0xFF339395),
        onRefresh: () => _loadAssessments(forceRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: HomeTabHeader(
                title: context.getText(AppKeys.parentAssessmentTabTitle),
                topInset: topInset,
                scale: scale,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                14 * scale,
                16 * scale,
                widget.args.bottomPadding + 20 * scale,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ParentPracticeTabBanner(
                    onTap: _openAssessment,
                    scale: scale,
                  ),
                  SizedBox(height: 13 * scale),
                  _ParentAssessmentSearchField(
                    controller: _searchController,
                    scale: scale,
                  ),
                  SizedBox(height: 20 * scale),
                  Text(
                    context.getText(AppKeys.parentLearningProgress),
                    style: TextStyle(
                      color: const Color(0xFF17252B),
                      fontSize: FontSize.large * scale,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  _ParentAssessmentProgressChart(
                    entries: _entries.take(5).toList().reversed.toList(),
                    scale: scale,
                  ),
                  SizedBox(height: 16 * scale),
                  if (isInitialLoading)
                    _ParentAssessmentListSkeleton(scale: scale)
                  else if (_errorMessage != null && _entries.isEmpty)
                    _initialFadeIn(
                      child: _ParentAssessmentStateCard(
                        icon: Icons.cloud_off_rounded,
                        title: context.getText(AppKeys.historyLoadErrorTitle),
                        message: _errorMessage!,
                        onTap: _loadAssessments,
                        scale: scale,
                      ),
                    )
                  else if (entries.isEmpty)
                    _initialFadeIn(
                      child: _ParentAssessmentStateCard(
                        icon: Icons.assignment_turned_in_outlined,
                        title: context.getText(AppKeys.noHistoryTitle),
                        message: context.getText(AppKeys.noHistoryMessage),
                        onTap: _loadAssessments,
                        scale: scale,
                      ),
                    )
                  else
                    _initialFadeIn(
                      child: Column(
                        children: [
                          for (final entry in entries) ...[
                            _ParentAssessmentTabCard(
                              entry: entry,
                              scale: scale,
                              onTap: () => _openQuizReview(entry.quiz),
                            ),
                            SizedBox(height: 14 * scale),
                          ],
                        ],
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialFadeIn({required Widget child}) {
    if (_hasPlayedInitialEntrance) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: homeFadeInDuration,
      curve: Curves.easeOut,
      onEnd: _markInitialEntrancePlayed,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 4 * (1 - value)),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }

  void _markInitialEntrancePlayed() {
    if (!mounted || _hasPlayedInitialEntrance) {
      return;
    }
    setState(() => _hasPlayedInitialEntrance = true);
  }
}
