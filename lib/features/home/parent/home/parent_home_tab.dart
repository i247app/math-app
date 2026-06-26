part of '../../home_screen.dart';

class _ParentHomeContent extends StatefulWidget {
  const _ParentHomeContent({required this.args});

  final HomeDashboardArgs args;

  @override
  State<_ParentHomeContent> createState() => _ParentHomeContentState();
}

class _ParentHomeContentState extends State<_ParentHomeContent> {
  late final HomeLayoutService _homeLayoutService = HomeLayoutApi();
  bool _isLoading = true;
  bool _hasLoadedHome = false;
  String? _errorMessage;
  HomeLayout? _homeLayout;
  List<GeneratedQuiz> _completedAssessments = const <GeneratedQuiz>[];
  List<_ParentChildSummary> _childSummaries = const <_ParentChildSummary>[];
  int _childLoadRequestId = 0;
  bool _hasPlayedInitialAssessmentEntrance = false;
  bool _hasPlayedCompletedAssessmentEntrance = false;
  bool _hasPlayedClassroomOverviewEntrance = false;

  @override
  void initState() {
    super.initState();
    if (widget.args.isActive) {
      _loadHome();
    }
  }

  @override
  void didUpdateWidget(covariant _ParentHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.args.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.args.activeProfile,
    );
    final oldChildIds = _studentProfiles(oldWidget.args.profiles)
        .map(ActiveProfileSession.profileStableId)
        .join(',');
    final childIds = _studentProfiles(widget.args.profiles)
        .map(ActiveProfileSession.profileStableId)
        .join(',');
    if (oldProfileId != profileId ||
        oldWidget.args.user?.id != widget.args.user?.id ||
        oldChildIds != childIds) {
      _hasLoadedHome = false;
      _resetModeEntrances();
      if (widget.args.isActive) {
        _loadHome();
      }
      return;
    }
    if (!oldWidget.args.isActive && widget.args.isActive) {
      _loadHome();
      return;
    }
    if (!widget.args.isActive) {
      return;
    } else if (oldWidget.args.activeRefreshTick !=
        widget.args.activeRefreshTick) {
      _loadHome();
    }
  }

  void _resetModeEntrances() {
    _hasPlayedInitialAssessmentEntrance = false;
    _hasPlayedCompletedAssessmentEntrance = false;
    _hasPlayedClassroomOverviewEntrance = false;
  }

  List<StudentProfile> get _children {
    final layoutChildren = _homeLayout?.parent?.children;
    if (layoutChildren != null &&
        (_hasLoadedHome || layoutChildren.isNotEmpty)) {
      return layoutChildren;
    }
    return _studentProfiles(widget.args.profiles);
  }

  Future<void> _loadHome() async {
    final requestId = ++_childLoadRequestId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.args.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoadedHome = true;
        _errorMessage = null;
        _homeLayout = null;
        _childSummaries = const <_ParentChildSummary>[];
        _completedAssessments = const <GeneratedQuiz>[];
      });
      widget.args.onParentAssessmentStateChanged(false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (!_hasLoadedHome) {
        _childSummaries = const <_ParentChildSummary>[];
        _completedAssessments = const <GeneratedQuiz>[];
      }
    });
    widget.args.onParentAssessmentStateChanged(false);

    try {
      final layout = await _homeLayoutService.getLayout(profileId: profileId);
      if (!mounted || requestId != _childLoadRequestId) {
        return;
      }
      final parent = layout.parent;
      final summaries = _summariesFromLayout(parent);
      final completedAssessments = _quizzesFromLayoutQuizzes(layout.quizzes);
      setState(() {
        _isLoading = false;
        _hasLoadedHome = true;
        _errorMessage = null;
        _homeLayout = layout;
        _childSummaries = summaries;
        _completedAssessments = completedAssessments;
      });
      widget.args.onParentAssessmentStateChanged(
        completedAssessments.isNotEmpty,
      );
    } on HomeLayoutException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoadedHome = true;
        _errorMessage = error.message;
        _homeLayout = null;
        _childSummaries = const <_ParentChildSummary>[];
        _completedAssessments = const <GeneratedQuiz>[];
      });
      widget.args.onParentAssessmentStateChanged(false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoadedHome = true;
        _errorMessage =
            context.readText(AppKeys.parentChildDashboardLoadFailed);
        _homeLayout = null;
        _childSummaries = const <_ParentChildSummary>[];
        _completedAssessments = const <GeneratedQuiz>[];
      });
      widget.args.onParentAssessmentStateChanged(false);
    }
  }

  Widget _initialAssessmentFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedInitialAssessmentEntrance) {
      return child;
    }

    return _ParentHomeEntrance(
      order: order,
      onFinished: markOnEnd ? _markInitialAssessmentEntrancePlayed : null,
      child: child,
    );
  }

  void _markInitialAssessmentEntrancePlayed() {
    if (!mounted || _hasPlayedInitialAssessmentEntrance) {
      return;
    }
    setState(() => _hasPlayedInitialAssessmentEntrance = true);
  }

  Widget _completedAssessmentFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedCompletedAssessmentEntrance) {
      return child;
    }

    return _ParentHomeEntrance(
      order: order,
      onFinished: markOnEnd ? _markCompletedAssessmentEntrancePlayed : null,
      child: child,
    );
  }

  void _markCompletedAssessmentEntrancePlayed() {
    if (!mounted || _hasPlayedCompletedAssessmentEntrance) {
      return;
    }
    setState(() => _hasPlayedCompletedAssessmentEntrance = true);
  }

  Widget _childOverviewFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedClassroomOverviewEntrance) {
      return child;
    }

    return _ParentHomeEntrance(
      order: order,
      onFinished: markOnEnd ? _markChildOverviewEntrancePlayed : null,
      child: child,
    );
  }

  void _markChildOverviewEntrancePlayed() {
    if (!mounted || _hasPlayedClassroomOverviewEntrance) {
      return;
    }
    setState(() => _hasPlayedClassroomOverviewEntrance = true);
  }

  @override
  Widget build(BuildContext context) {
    final hasJoinedClassroom = _childSummaries.any(
      (summary) => summary.classroom != null,
    );
    final isInitialChildDashboardLoad =
        _children.isNotEmpty && !_hasLoadedHome && _isLoading;
    if (_children.isNotEmpty &&
        (hasJoinedClassroom || isInitialChildDashboardLoad)) {
      return _buildChildDashboard();
    }

    final hasCompletedAssessment = _completedAssessments.isNotEmpty;
    final padding = EdgeInsets.fromLTRB(
      14 * widget.args.scale,
      widget.args.headerHeight,
      14 * widget.args.scale,
      widget.args.bottomPadding,
    );

    return RefreshIndicator(
      color: const Color(0xFF159A86),
      onRefresh: _loadHome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isLoading && !hasCompletedAssessment)
              _initialAssessmentFadeIn(
                order: 0,
                child: _ParentLearningStreakCard(
                  hasCompletedAssessment: hasCompletedAssessment,
                ),
              )
            else if (!_isLoading && hasCompletedAssessment)
              _completedAssessmentFadeIn(
                order: 0,
                child: _ParentLearningStreakCard(
                  hasCompletedAssessment: hasCompletedAssessment,
                ),
              )
            else
              _ParentLearningStreakCard(
                hasCompletedAssessment: hasCompletedAssessment,
              ),
            const SizedBox(height: 12),
            if (_isLoading && !_hasLoadedHome)
              const _ParentHomeLoadingCard()
            else if (hasCompletedAssessment)
              _buildCompletedState()
            else
              _buildFirstAssessmentState(),
            if (_isLoading && _hasLoadedHome) ...[
              const SizedBox(height: 8),
              const _ParentHomeRefreshLabel(),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              _ParentHomeErrorCard(
                message: _errorMessage!,
                onRetry: _loadHome,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openAssessment() async {
    HapticFeedback.lightImpact();
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
          initialGradeId: _profileGradeId(widget.args.activeProfile),
          initialGradeLabel: widget.args.activeProfile?.grade?.label,
        ),
      ),
    );
    if (mounted) {
      await _loadHome();
    }
  }

  void _openParentAssessmentResult(GeneratedQuiz quiz) {
    _openQuizReview(quiz);
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
      await _loadHome();
    }
  }

  void _openQuizReview(GeneratedQuiz quiz) {
    final quizId = quiz.quizId ?? quiz.id;
    if (quizId == null || quizId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizReviewScreen(
          quizId: quizId,
          initialQuiz: quiz,
        ),
      ),
    );
  }

  Future<void> _showClassroomMessage() async {
    HapticFeedback.selectionClick();
    if (_children.isEmpty) {
      final shouldCreate = await showDialog<bool>(
        context: context,
        barrierColor: const Color(0xFF001741).withValues(alpha: 0.48),
        builder: (_) => const _HomeMissingStudentDialog(),
      );
      if (shouldCreate == true && mounted) {
        await _openCreateStudentProfile();
      }
      return;
    }

    final action = await showDialog<_ParentProfileDialogAction>(
      context: context,
      barrierColor: const Color(0xFF001741).withValues(alpha: 0.48),
      builder: (_) => const _ParentSelectStudentDialog(),
    );
    if (!mounted) {
      return;
    }
    switch (action) {
      case _ParentProfileDialogAction.choose:
        widget.args.onOpenProfileMenu();
        return;
      case _ParentProfileDialogAction.create:
        await _openCreateStudentProfile();
        return;
      case null:
        return;
    }
  }

  Future<void> _openCreateStudentProfile() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Material(
          color: Colors.white,
          child: SafeArea(
            child: SettingTab.page(
              user: widget.args.user,
              profiles: widget.args.profiles,
              activeProfile: widget.args.activeProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: widget.args.onActivateProfile,
              onRefreshProfiles: widget.args.onRefreshProfiles,
              onProfileSaved: widget.args.onProfileSaved,
              bottomPadding: 0,
              scale: widget.args.scale,
              initialView: SettingPageView.profile,
              isPushedPage: true,
              openAddProfileOnStart: true,
            ),
          ),
        ),
      ),
    );
    await widget.args.onRefreshProfiles();
  }
}
