part of '../home_screen.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({
    super.key,
    required this.args,
  });

  final HomeDashboardArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return _ParentHomeContent(args: args);
    }

    if (args.activeTab == 1) {
      return ParentAssessmentTab(args: args);
    }

    if (args.activeTab == 2) {
      return ParentRoomTab(args: args);
    }

    if (args.activeTab == 3) {
      return GamesTab(
        userId: args.user?.id,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        initialGradeId: _profileGradeId(args.activeProfile),
        initialGradeLabel: args.activeProfile?.grade?.label,
        bottomPadding: args.bottomPadding,
      );
    }

    if (args.activeTab == 4) {
      return _dashboardSettings(args);
    }

    return const SizedBox.shrink();
  }
}

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
  bool _hasPlayedModeOneEntrance = false;
  bool _hasPlayedModeTwoEntrance = false;
  bool _hasPlayedModeThreeEntrance = false;

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
    _hasPlayedModeOneEntrance = false;
    _hasPlayedModeTwoEntrance = false;
    _hasPlayedModeThreeEntrance = false;
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

  Widget _modeOneFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedModeOneEntrance) {
      return child;
    }

    return _ParentHomeEntrance(
      order: order,
      onFinished: markOnEnd ? _markModeOneEntrancePlayed : null,
      child: child,
    );
  }

  void _markModeOneEntrancePlayed() {
    if (!mounted || _hasPlayedModeOneEntrance) {
      return;
    }
    setState(() => _hasPlayedModeOneEntrance = true);
  }

  Widget _modeTwoFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedModeTwoEntrance) {
      return child;
    }

    return _ParentHomeEntrance(
      order: order,
      onFinished: markOnEnd ? _markModeTwoEntrancePlayed : null,
      child: child,
    );
  }

  void _markModeTwoEntrancePlayed() {
    if (!mounted || _hasPlayedModeTwoEntrance) {
      return;
    }
    setState(() => _hasPlayedModeTwoEntrance = true);
  }

  Widget _modeThreeFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedModeThreeEntrance) {
      return child;
    }

    return _ParentHomeEntrance(
      order: order,
      onFinished: markOnEnd ? _markModeThreeEntrancePlayed : null,
      child: child,
    );
  }

  void _markModeThreeEntrancePlayed() {
    if (!mounted || _hasPlayedModeThreeEntrance) {
      return;
    }
    setState(() => _hasPlayedModeThreeEntrance = true);
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
              _modeOneFadeIn(
                order: 0,
                child: _ParentLearningStreakCard(
                  hasCompletedAssessment: hasCompletedAssessment,
                ),
              )
            else if (!_isLoading && hasCompletedAssessment)
              _modeTwoFadeIn(
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
        builder: (_) => const _ParentNoStudentDialog(),
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

class _ParentHomeRefreshLabel extends StatelessWidget {
  const _ParentHomeRefreshLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.getText(AppKeys.loading),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF6D5C5C),
        fontSize: FontSize.caption,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

enum _ParentProfileDialogAction { choose, create }

class _ParentSelectStudentDialog extends StatelessWidget {
  const _ParentSelectStudentDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: 303,
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.42),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 155,
                      height: 155,
                      decoration: BoxDecoration(
                        color: const Color(0xFFAA2A6C).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFAA2A6C).withValues(alpha: 0.14),
                            blurRadius: 26,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      _parentNoStudentMascot,
                      width: 176,
                      height: 158,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  context.getText(AppKeys.parentNoStudentTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF001741),
                    fontSize: FontSize.title,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.getText(AppKeys.parentSelectStudentMessage),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF444650),
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      _ParentProfileDialogAction.choose,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFAA2A6C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.getText(AppKeys.parentSwitchStudentAction),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(
                      _ParentProfileDialogAction.create,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFAA2A6C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      context.getText(AppKeys.parentCreateStudent),
                      style: const TextStyle(
                        color: Color(0xFFAA2A6C),
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParentChildSummary {
  const _ParentChildSummary({
    required this.profile,
    this.classroom,
    this.assessments = const <GeneratedQuiz>[],
  });

  final StudentProfile profile;
  final ClassroomModel? classroom;
  final List<GeneratedQuiz> assessments;
}

typedef _ParentHomeEntranceBuilder = Widget Function({
  required Widget child,
  int order,
  bool markOnEnd,
});

class _ParentModeThreeContent extends StatelessWidget {
  const _ParentModeThreeContent({
    required this.summaries,
    required this.pendingExercises,
    required this.completions,
    required this.entranceBuilder,
    required this.onPendingTap,
    required this.onCompletionTap,
    required this.onViewTasks,
    required this.onViewResults,
    required this.onViewMessages,
    required this.isRefreshing,
    required this.errorMessage,
    required this.onRetry,
  });

  final List<_ParentChildSummary> summaries;
  final List<HomeLayoutPendingExercise> pendingExercises;
  final List<HomeLayoutRecentCompletion> completions;
  final _ParentHomeEntranceBuilder entranceBuilder;
  final ValueChanged<HomeLayoutPendingExercise> onPendingTap;
  final ValueChanged<HomeLayoutRecentCompletion> onCompletionTap;
  final VoidCallback onViewTasks;
  final VoidCallback onViewResults;
  final VoidCallback onViewMessages;
  final bool isRefreshing;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final primarySummary = _parentPrimarySummary(summaries);
    final showGameSuggestions = pendingExercises.isEmpty || completions.isEmpty;
    final visiblePendingExercises =
        pendingExercises.take(2).toList(growable: false);
    final visibleCompletions = completions.take(2).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        entranceBuilder(
          order: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ParentModeThreeClassCard(summary: primarySummary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (pendingExercises.isNotEmpty) ...[
          entranceBuilder(
            order: 1,
            child: _ParentModeThreeSection(
              title: 'Nhiệm vụ',
              onViewAll: pendingExercises.length > 2 ? onViewTasks : null,
              child: Column(
                children: [
                  for (var index = 0;
                      index < visiblePendingExercises.length;
                      index++) ...[
                    _ParentRoomPendingListItem(
                      pending: visiblePendingExercises[index],
                      onTap: () => onPendingTap(visiblePendingExercises[index]),
                    ),
                    if (index != visiblePendingExercises.length - 1)
                      const Divider(
                        height: 24,
                        indent: 62,
                        color: Colors.black87,
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (completions.isNotEmpty) ...[
          entranceBuilder(
            order: 2,
            child: _ParentModeThreeSection(
              title: context.getText(AppKeys.assessmentResultTitle),
              onViewAll: completions.length > 2 ? onViewResults : null,
              child: Column(
                children: [
                  for (var index = 0;
                      index < visibleCompletions.length;
                      index++) ...[
                    _ParentModeThreeResultItem(
                      completion: visibleCompletions[index],
                      onTap: () => onCompletionTap(visibleCompletions[index]),
                    ),
                    if (index != visibleCompletions.length - 1)
                      const Divider(
                        height: 24,
                        indent: 62,
                        color: Color(0xFFE9EEF2),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        entranceBuilder(
          order: 3,
          markOnEnd: !showGameSuggestions,
          child: _ParentModeThreeSection(
            title: 'Tin nhắn',
            onViewAll: onViewMessages,
            child: _ParentModeThreeMessages(summaries: summaries),
          ),
        ),
        if (showGameSuggestions) ...[
          const SizedBox(height: 14),
          entranceBuilder(
            order: 4,
            markOnEnd: true,
            child: const _ParentModeThreeGameSuggestions(),
          ),
        ],
        if (isRefreshing) ...[
          const SizedBox(height: 8),
          const _ParentHomeRefreshLabel(),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          _ParentHomeErrorCard(message: errorMessage!, onRetry: onRetry),
        ],
      ],
    );
  }
}

class _ParentModeThreeGameSuggestions extends StatelessWidget {
  const _ParentModeThreeGameSuggestions();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StudentGamePreviewCard(
            asset: 'assets/images/game_numi_farm_banner.png',
            background: Color(0xFFDDF3EE),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StudentGamePreviewCard(
            background: Color(0xFF111C4B),
            child: _StudentMathSquadronPreviewArtwork(),
          ),
        ),
      ],
    );
  }
}

class _ParentModeThreeClassCard extends StatelessWidget {
  const _ParentModeThreeClassCard({required this.summary});

  final _ParentChildSummary? summary;

  @override
  Widget build(BuildContext context) {
    final className = summary == null
        ? context.getText(AppKeys.parentNoClassroom)
        : _parentClassroomName(context, summary!);
    final teacherName = summary?.classroom?.teacherName?.trim();

    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBE6E4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            summary == null
                ? context.getText(AppKeys.parentNoStudentTitle)
                : homeProfileDisplayName(context, summary!.profile),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF276C6B),
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            className,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF276C6B),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            teacherName?.isNotEmpty == true
                ? teacherName!
                : context.getText(AppKeys.parentNoTeacher),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF276C6B),
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentModeThreeSection extends StatelessWidget {
  const _ParentModeThreeSection({
    required this.title,
    required this.child,
    this.onViewAll,
  });

  final String title;
  final Widget child;
  final VoidCallback? onViewAll;

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
              if (onViewAll != null)
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

class _ParentModeThreeResultItem extends StatelessWidget {
  const _ParentModeThreeResultItem({
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
    final classroomName = completion.classroom?.name?.trim();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            _ParentModeThreeScore(score: score, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ParentRoomBadgeRow(
                          childName: completion.child == null
                              ? null
                              : homeProfileDisplayName(
                                  context,
                                  completion.child!,
                                ),
                          classroomName: classroomName?.isNotEmpty == true
                              ? classroomName!
                              : context.getText(AppKeys.teacherClassFallback),
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
                    title: _parentExerciseTitle(context, exercise),
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

class _ParentModeThreeIconBox extends StatelessWidget {
  const _ParentModeThreeIconBox({
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
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _ParentModeThreeScore extends StatelessWidget {
  const _ParentModeThreeScore({
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

class _ParentModeThreeEmptyLine extends StatelessWidget {
  const _ParentModeThreeEmptyLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ParentModeThreeIconBox(
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

class _ParentModeThreeMessages extends StatelessWidget {
  const _ParentModeThreeMessages({required this.summaries});

  final List<_ParentChildSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final visibleSummaries = summaries.take(2).toList(growable: false);
    if (visibleSummaries.isEmpty) {
      return _ParentModeThreeEmptyLine(
        icon: Icons.mail_outline_rounded,
        text: context.getText(AppKeys.homeMessageBodyOne),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < visibleSummaries.length; index++) ...[
          _ParentModeThreeMessageItem(
            summary: visibleSummaries[index],
            index: index,
          ),
          if (index != visibleSummaries.length - 1)
            const Divider(height: 24, color: Color(0xFFE9EEF2)),
        ],
      ],
    );
  }
}

class _ParentModeThreeMessageItem extends StatelessWidget {
  const _ParentModeThreeMessageItem({
    required this.summary,
    required this.index,
  });

  final _ParentChildSummary summary;
  final int index;

  @override
  Widget build(BuildContext context) {
    final childName = homeProfileDisplayName(context, summary.profile);
    final className = _parentClassroomName(context, summary);
    final teacherName = context.getText(
      index.isEven
          ? AppKeys.homeMessageTeacherOne
          : AppKeys.homeMessageTeacherTwo,
    );
    final time = context.getText(
      index.isEven ? AppKeys.homeMessageTimeOne : AppKeys.homeMessageTimeTwo,
    );
    final body = context.getText(
      index.isEven ? AppKeys.homeMessageBodyOne : AppKeys.homeMessageBodyTwo,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              index.isEven ? _homeTeacherAvatarOne : _homeTeacherAvatarTwo,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF17233F),
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF8B9BB1),
                        fontSize: FontSize.caption * 0.74,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$className - ${childName.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8390A5),
                    fontSize: FontSize.caption * 0.76,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF697895),
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w600,
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

_ParentChildSummary? _parentPrimarySummary(
  List<_ParentChildSummary> summaries,
) {
  for (final summary in summaries) {
    if (summary.classroom != null) {
      return summary;
    }
  }
  return summaries.isEmpty ? null : summaries.first;
}

String _parentExerciseTitle(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final title = exercise?.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  return context.getText(AppKeys.studentHomework);
}

List<_ParentChildSummary> _summariesFromLayout(ParentHomeLayout? parent) {
  final children = parent?.children ?? const <StudentProfile>[];
  if (children.isEmpty) {
    return const <_ParentChildSummary>[];
  }

  return children.map((child) {
    final childId = ActiveProfileSession.profileStableId(child);
    final assessments = <GeneratedQuiz>[
      for (final completion
          in parent?.recentCompletions ?? const <HomeLayoutRecentCompletion>[])
        if (_layoutChildId(completion.child) == childId)
          _quizFromRecentCompletion(completion),
    ]..sort((a, b) => _quizDate(b).compareTo(_quizDate(a)));

    return _ParentChildSummary(
      profile: child,
      classroom: _classroomForLayoutChild(parent, child),
      assessments: assessments,
    );
  }).toList(growable: false);
}

List<GeneratedQuiz> _quizzesFromLayoutQuizzes(List<HomeLayoutQuiz> quizzes) {
  return <GeneratedQuiz>[
    for (final quiz in quizzes)
      GeneratedQuiz(
        id: quiz.quizId,
        quizId: quiz.quizId,
        quizStatus: quiz.quizStatus,
        purpose: quiz.purpose,
        type: quiz.purpose,
        typeOfQuiz: quiz.typeOfQuiz,
        title: quiz.title,
        shortText: quiz.shortText,
        createDt: quiz.createDt,
        modifyDt: quiz.createDt,
        grading: QuizGrading(
          correctNumber: quiz.correctNumber,
          scorePercentage: quiz.scorePercentage,
          totalQuestions: quiz.totalQuestions,
        ),
        questions: const <QuizQuestion>[],
      ),
  ]..sort((a, b) => _quizDate(b).compareTo(_quizDate(a)));
}

ClassroomModel? _classroomForLayoutChild(
  ParentHomeLayout? parent,
  StudentProfile child,
) {
  if (parent == null) {
    return null;
  }

  final childId = ActiveProfileSession.profileStableId(child);
  for (final classroom in parent.classrooms) {
    if (classroom.memberProfileId == childId) {
      return classroom.classroom;
    }
  }

  if (parent.children.length == 1 && parent.classrooms.length == 1) {
    return parent.classrooms.first.classroom;
  }

  for (final completion in parent.recentCompletions) {
    if (_layoutChildId(completion.child) == childId &&
        completion.classroom != null) {
      final classroomId =
          completion.classroomId ?? completion.exercise?.classroomId;
      final matchingClassroom = _layoutClassroomById(parent, classroomId);
      if (matchingClassroom != null) {
        return matchingClassroom;
      }
      return completion.classroom;
    }
  }

  for (final pending in parent.pendingExercises) {
    if (_layoutChildId(pending.child) == childId && pending.classroom != null) {
      final classroomId = pending.classroomId ?? pending.exercise?.classroomId;
      final matchingClassroom = _layoutClassroomById(parent, classroomId);
      if (matchingClassroom != null) {
        return matchingClassroom;
      }
      return pending.classroom;
    }
  }

  for (final expired in parent.expiredExercises) {
    if (_layoutChildId(expired.child) == childId && expired.classroom != null) {
      final classroomId = expired.classroomId ?? expired.exercise?.classroomId;
      final matchingClassroom = _layoutClassroomById(parent, classroomId);
      if (matchingClassroom != null) {
        return matchingClassroom;
      }
      return expired.classroom;
    }
  }

  return null;
}

ClassroomModel? _layoutClassroomById(
    ParentHomeLayout parent, int? classroomId) {
  if (classroomId == null) {
    return null;
  }
  for (final layoutClassroom in parent.classrooms) {
    if (layoutClassroom.classroom.stableId == classroomId) {
      return layoutClassroom.classroom;
    }
  }
  return null;
}

GeneratedQuiz _quizFromRecentCompletion(HomeLayoutRecentCompletion completion) {
  final exercise = completion.exercise;
  final exerciseId = completion.classroomExerciseId ??
      exercise?.classroomExerciseId ??
      exercise?.exerciseId ??
      exercise?.id;
  final totalQuestions = completion.totalQuestions ?? exercise?.numQuestions;
  return GeneratedQuiz(
    id: exerciseId,
    quizId: exerciseId,
    profileId: _layoutChildId(completion.child),
    quizStatus: completion.submissionStatus,
    purpose: exercise?.purpose,
    type: exercise?.purpose,
    title: exercise?.title,
    shortText: exercise?.shortText ?? exercise?.description,
    createDt: completion.submittedDt ?? exercise?.createDt,
    modifyDt:
        completion.gradedDt ?? completion.submittedDt ?? exercise?.modifyDt,
    grading: QuizGrading(
      correctNumber: completion.correctNumber,
      scorePercentage: completion.scorePercentage,
      totalQuestions: totalQuestions,
    ),
    questions: const <QuizQuestion>[],
  );
}

StudentHomeworkResultSummary _homeworkSummaryFromCompletion(
  BuildContext context,
  HomeLayoutRecentCompletion completion,
) {
  final scorePercentage = completion.scorePercentage;
  if (scorePercentage != null) {
    final scoreOutOf10 = (scorePercentage / 10).round().clamp(0, 10);
    return StudentHomeworkResultSummary(
      scoreText: '$scoreOutOf10/10',
      reviewText: context.getText(AppKeys.defaultAiReview),
    );
  }

  final correctNumber = completion.correctNumber;
  final totalQuestions = completion.totalQuestions;
  if (correctNumber != null && totalQuestions != null && totalQuestions > 0) {
    final scoreOutOf10 = (correctNumber / totalQuestions * 10).round();
    return StudentHomeworkResultSummary(
      scoreText: '${scoreOutOf10.clamp(0, 10)}/10',
      reviewText: context.getText(AppKeys.defaultAiReview),
    );
  }

  return StudentHomeworkResultSummary(
    scoreText: '--/10',
    reviewText: context.getText(AppKeys.defaultAiReview),
  );
}

int? _layoutChildId(StudentProfile? child) {
  return child == null ? null : ActiveProfileSession.profileStableId(child);
}

class _ParentChildDashboardLoading extends StatefulWidget {
  const _ParentChildDashboardLoading();

  @override
  State<_ParentChildDashboardLoading> createState() =>
      _ParentChildDashboardLoadingState();
}

class _ParentChildDashboardLoadingState
    extends State<_ParentChildDashboardLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

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
        final color = Color.lerp(
          const Color(0xFFF1F3F3),
          const Color(0xFFE1E8E7),
          _controller.value,
        )!;
        return Column(
          children: [
            Row(
              children: [
                for (var index = 0; index < 2; index++) ...[
                  Expanded(
                    child: _ParentSkeletonBlock(
                      height: 121,
                      radius: 18,
                      color: color,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 22,
                        ),
                        child: Column(
                          children: [
                            _ParentSkeletonLine(
                              width: 70,
                              height: 12,
                              color: color,
                            ),
                            const SizedBox(height: 12),
                            _ParentSkeletonLine(
                              width: 88,
                              height: 28,
                              color: color,
                            ),
                            const SizedBox(height: 12),
                            _ParentSkeletonLine(
                              width: 96,
                              height: 10,
                              color: color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index == 0) const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < 2; index++) ...[
              _ParentSkeletonBlock(
                height: 98,
                radius: 18,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      _ParentSkeletonBlock(
                        width: 50,
                        height: 50,
                        radius: 25,
                        color: color,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ParentSkeletonLine(
                              width: 94,
                              height: 10,
                              color: color,
                            ),
                            const SizedBox(height: 10),
                            _ParentSkeletonLine(
                              width: double.infinity,
                              height: 16,
                              color: color,
                            ),
                            const SizedBox(height: 8),
                            _ParentSkeletonLine(
                              width: 120,
                              height: 10,
                              color: color,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            for (var index = 0; index < 2; index++) ...[
              _ParentSkeletonBlock(
                height: 190,
                radius: 22,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _ParentSkeletonBlock(
                            width: 48,
                            height: 48,
                            radius: 13,
                            color: color,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ParentSkeletonLine(
                                  width: 135,
                                  height: 15,
                                  color: color,
                                ),
                                const SizedBox(height: 8),
                                _ParentSkeletonLine(
                                  width: 70,
                                  height: 9,
                                  color: color,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _ParentSkeletonBlock(
                          radius: 13,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index == 0) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ParentSkeletonBlock extends StatelessWidget {
  const _ParentSkeletonBlock({
    this.width,
    this.height,
    required this.radius,
    required this.color,
    this.child,
  });

  final double? width;
  final double? height;
  final double radius;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE8ECEB)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}

class _ParentSkeletonLine extends StatelessWidget {
  const _ParentSkeletonLine({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height),
        ),
      ),
    );
  }
}

class _ParentHomeEntrance extends StatefulWidget {
  const _ParentHomeEntrance({
    required this.order,
    required this.child,
    this.onFinished,
  });

  final int order;
  final Widget child;
  final VoidCallback? onFinished;

  @override
  State<_ParentHomeEntrance> createState() => _ParentHomeEntranceState();
}

class _ParentHomeEntranceState extends State<_ParentHomeEntrance> {
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

    return AnimatedSlide(
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
    );
  }
}

class _ParentSkeletonShimmer extends StatelessWidget {
  const _ParentSkeletonShimmer({
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final width = bounds.width;
        final shimmerWidth = width * 0.42;
        final start = -shimmerWidth + (width + shimmerWidth * 2) * progress;

        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Colors.transparent,
            Color(0x99FFFFFF),
            Colors.transparent,
          ],
          stops: const [0.18, 0.50, 0.82],
          transform: _ParentShimmerTransform(start),
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class _ParentShimmerTransform extends GradientTransform {
  const _ParentShimmerTransform(this.dx);

  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0, 0);
  }
}

class _ParentLearningStreakCard extends StatelessWidget {
  const _ParentLearningStreakCard({
    required this.hasCompletedAssessment,
  });

  final bool hasCompletedAssessment;

  @override
  Widget build(BuildContext context) {
    const dayLabels = <String>['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final states = hasCompletedAssessment
        ? const <_ParentStreakDayState>[
            _ParentStreakDayState.done,
            _ParentStreakDayState.done,
            _ParentStreakDayState.done,
            _ParentStreakDayState.current,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
          ]
        : const <_ParentStreakDayState>[
            _ParentStreakDayState.current,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
          ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFF0DFD8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.getText(AppKeys.parentLearningStreak),
            style: const TextStyle(
              color: Color(0xFF282828),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dayLabels.length,
              (index) => _ParentStreakDay(
                label: dayLabels[index],
                state: states[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ParentStreakDayState { done, current, upcoming }

class _ParentStreakDay extends StatelessWidget {
  const _ParentStreakDay({
    required this.label,
    required this.state,
  });

  final String label;
  final _ParentStreakDayState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9A6B61),
            fontSize: FontSize.caption * 0.77,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 31,
          height: 31,
          child: switch (state) {
            _ParentStreakDayState.done => const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF4FB465),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            _ParentStreakDayState.current => const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFF5F19),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            _ParentStreakDayState.upcoming => const CustomPaint(
                painter: _ParentDashedCirclePainter(),
                child: Center(
                  child: Text(
                    '5',
                    style: TextStyle(
                      color: Color(0xFFC98E7E),
                      fontSize: FontSize.caption,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          },
        ),
      ],
    );
  }
}

class _ParentDashedCirclePainter extends CustomPainter {
  const _ParentDashedCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE6B5A7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final radius = (math.min(size.width, size.height) - paint.strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
    const dashAngle = 0.22;
    const gapAngle = 0.20;
    for (double start = 0; start < math.pi * 2; start += dashAngle + gapAngle) {
      canvas.drawArc(rect, start, dashAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ParentImageAction extends StatelessWidget {
  const _ParentImageAction({
    required this.asset,
    required this.height,
    required this.onTap,
    this.alignment = Alignment.center,
  });

  final String asset;
  final double height;
  final VoidCallback onTap;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Ink.image(
            image: AssetImage(asset),
            fit: BoxFit.cover,
            alignment: alignment,
          ),
        ),
      ),
    );
  }
}

class _ParentStartGuideCard extends StatelessWidget {
  const _ParentStartGuideCard({
    required this.onAssessmentTap,
    required this.onRoadmapTap,
    required this.onClassroomTap,
  });

  final VoidCallback onAssessmentTap;
  final VoidCallback onRoadmapTap;
  final VoidCallback onClassroomTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE4E1E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ParentGuideItem(
            icon: Icons.fact_check_rounded,
            color: const Color(0xFF069C95),
            title: context.getText(AppKeys.parentAssessmentTitle),
            subtitle: context.getText(AppKeys.parentAssessmentSubtitle),
            onTap: onAssessmentTap,
          ),
          const SizedBox(height: 10),
          _ParentGuideItem(
            icon: Icons.sports_esports_rounded,
            color: const Color(0xFFFF6636),
            title: context.getText(AppKeys.parentRoadmapTitle),
            subtitle: context.getText(AppKeys.parentRoadmapSubtitle),
            onTap: onRoadmapTap,
          ),
          const SizedBox(height: 10),
          _ParentGuideItem(
            icon: Icons.meeting_room_rounded,
            color: const Color(0xFF6451A6),
            title: context.getText(AppKeys.parentJoinRoomTitle),
            subtitle: context.getText(AppKeys.parentJoinRoomSubtitle),
            onTap: onClassroomTap,
          ),
        ],
      ),
    );
  }
}

class _ParentGuideItem extends StatelessWidget {
  const _ParentGuideItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6D5C5C),
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
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

class _ParentAssessmentResultCard extends StatelessWidget {
  const _ParentAssessmentResultCard({
    required this.quiz,
    required this.onTap,
  });

  final GeneratedQuiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (quiz.grading?.scorePercentage ?? 0).clamp(0, 100);
    final score = (percent / 10).round();
    final scoreColor =
        score >= 8 ? const Color(0xFF087D47) : const Color(0xFFFF6B17);
    final shortText = _parentQuizShortText(quiz);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.fromLTRB(18, 14, 13, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE9E4E4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: math.max(percent / 100, 0.08),
                      strokeWidth: 5,
                      backgroundColor: scoreColor.withValues(alpha: 0.12),
                      color: scoreColor,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: FontSize.title,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF575757),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _parentQuizDateLabel(quiz),
                          style: const TextStyle(
                            color: Color(0xFF595959),
                            fontSize: FontSize.caption,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _parentQuizTitle(context, quiz),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: FontSize.normal,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    if (shortText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        shortText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6D5C58),
                          fontSize: FontSize.small,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8DA4BD),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentHomeLoadingCard extends StatefulWidget {
  const _ParentHomeLoadingCard();

  @override
  State<_ParentHomeLoadingCard> createState() => _ParentHomeLoadingCardState();
}

class _ParentHomeLoadingCardState extends State<_ParentHomeLoadingCard>
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
        final pulseValue =
            0.5 - 0.5 * math.cos(math.pi * 2 * _controller.value);
        final color = Color.lerp(
          const Color(0xFFF1F3F3),
          const Color(0xFFE1E8E7),
          pulseValue,
        )!;

        return _ParentSkeletonShimmer(
          progress: _controller.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ParentSkeletonBlock(
                height: 225,
                radius: 30,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ParentSkeletonLine(
                        width: 148,
                        height: 30,
                        color: color,
                      ),
                      const SizedBox(height: 14),
                      _ParentSkeletonLine(
                        width: 210,
                        height: 34,
                        color: color,
                      ),
                      const Spacer(),
                      _ParentSkeletonLine(
                        width: 132,
                        height: 14,
                        color: color,
                      ),
                      const SizedBox(height: 12),
                      _ParentSkeletonBlock(
                        width: 150,
                        height: 44,
                        radius: 22,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ParentSkeletonBlock(
                      height: 160,
                      radius: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ParentSkeletonBlock(
                      height: 160,
                      radius: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ParentSkeletonBlock(
                height: 178,
                radius: 17,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (var index = 0; index < 3; index++) ...[
                        Row(
                          children: [
                            _ParentSkeletonBlock(
                              width: 32,
                              height: 32,
                              radius: 10,
                              color: color,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ParentSkeletonLine(
                                    width: index == 0 ? 120 : 150,
                                    height: 14,
                                    color: color,
                                  ),
                                  const SizedBox(height: 7),
                                  _ParentSkeletonLine(
                                    width: double.infinity,
                                    height: 10,
                                    color: color,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (index != 2) const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ParentHomeErrorCard extends StatelessWidget {
  const _ParentHomeErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF8A4433),
                fontSize: FontSize.caption,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(context.getText(AppKeys.parentTryAgain)),
          ),
        ],
      ),
    );
  }
}

bool _isCompletedAssessment(GeneratedQuiz quiz) {
  final purpose = (quiz.purpose ?? quiz.type ?? '').trim().toUpperCase();
  final status = quiz.quizStatus?.trim().toUpperCase();
  return purpose == quizPurposeAssessment &&
      (status == 'SUBMITTED' || quiz.grading?.scorePercentage != null);
}

Future<List<GeneratedQuiz>> _loadCompletedParentAssessments({
  required QuizService quizService,
  required int? profileId,
  required int? userId,
}) async {
  List<GeneratedQuiz> completed(List<GeneratedQuiz> quizzes) {
    return quizzes.where(_isCompletedAssessment).toList(growable: false)
      ..sort((a, b) => _quizDate(b).compareTo(_quizDate(a)));
  }

  Object? profileError;
  if (profileId != null && profileId > 0) {
    try {
      final profileQuizzes = await quizService.listQuizzes(
        profileId: profileId,
      );
      final profileAssessments = completed(profileQuizzes);
      if (profileAssessments.isNotEmpty) {
        return profileAssessments;
      }
    } catch (error) {
      profileError = error;
    }
  }

  if (userId != null && userId > 0) {
    try {
      final userQuizzes = await quizService.listQuizzes(userId: userId);
      return completed(userQuizzes);
    } catch (_) {
      if (profileError != null) {
        Error.throwWithStackTrace(profileError, StackTrace.current);
      }
      rethrow;
    }
  }

  if (profileError != null) {
    Error.throwWithStackTrace(profileError, StackTrace.current);
  }
  return const <GeneratedQuiz>[];
}

DateTime _quizDate(GeneratedQuiz quiz) {
  return DateTime.tryParse(quiz.modifyDt ?? quiz.createDt ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _parentQuizDateLabel(GeneratedQuiz quiz) {
  final date = _quizDate(quiz).toLocal();
  if (date.millisecondsSinceEpoch == 0) {
    return '--/--/----';
  }
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _parentQuizTitle(BuildContext context, GeneratedQuiz quiz) {
  final title = quiz.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final grade = quiz.grading?.aiDetectGrade?.trim();
  if (grade != null && grade.isNotEmpty) {
    return '${context.getText(AppKeys.mathAssessment)} $grade';
  }
  return context.getText(AppKeys.mathAssessment);
}

String? _parentQuizShortText(GeneratedQuiz quiz) {
  final shortText = quiz.shortText?.trim();
  if (shortText == null || shortText.isEmpty) {
    return null;
  }
  return shortText;
}

List<StudentProfile> _studentProfiles(List<StudentProfile> profiles) {
  return profiles
      .where(
        (profile) => ProfileRole.fromProfile(profile) == ProfileRole.student,
      )
      .toList(growable: false);
}

String _parentClassroomName(
  BuildContext context,
  _ParentChildSummary summary,
) {
  final name = summary.classroom?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  final grade = summary.profile.grade?.label?.trim();
  if (grade != null && grade.isNotEmpty) {
    return grade;
  }
  return context.getText(AppKeys.parentNoClassroom);
}
