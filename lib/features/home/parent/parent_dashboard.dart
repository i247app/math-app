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
  bool _isLoading = true;
  bool _hasLoadedHome = false;
  String? _errorMessage;
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
    if (!oldWidget.args.isActive && widget.args.isActive) {
      _loadHome();
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
      _loadHome();
    } else if (oldWidget.args.activeRefreshTick !=
        widget.args.activeRefreshTick) {
      _loadHome();
    }
  }

  List<StudentProfile> get _children => _studentProfiles(widget.args.profiles);

  Future<void> _loadHome() {
    return _children.isNotEmpty ? _loadChildDashboard() : _loadAssessments();
  }

  Future<void> _loadChildDashboard() async {
    final requestId = ++_childLoadRequestId;
    final children = _children;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (_childSummaries.isEmpty) {
        _completedAssessments = const <GeneratedQuiz>[];
      }
    });
    widget.args.onParentAssessmentStateChanged(false);

    var hadError = false;
    final summariesFuture = Future.wait(
      children.map((profile) async {
        final profileId = ActiveProfileSession.profileStableId(profile);
        if (profileId == null || profileId <= 0) {
          hadError = true;
          return _ParentChildSummary(profile: profile);
        }

        List<ClassroomModel> classrooms = const <ClassroomModel>[];
        List<GeneratedQuiz> assessments = const <GeneratedQuiz>[];
        try {
          classrooms = await widget.args.classroomService
              .listMyJoinedClassrooms(profileId: profileId);
        } catch (_) {
          hadError = true;
        }
        try {
          final quizzes = await widget.args.quizService.listQuizzes(
            profileId: profileId,
          );
          assessments = quizzes
              .where(_isCompletedAssessment)
              .toList(growable: false)
            ..sort((a, b) => _quizDate(b).compareTo(_quizDate(a)));
        } catch (_) {
          hadError = true;
        }

        return _ParentChildSummary(
          profile: profile,
          classroom: classrooms.isEmpty ? null : classrooms.first,
          assessments: assessments,
        );
      }),
    );
    final parentAssessmentsFuture = _loadParentAssessments(
      onError: () => hadError = true,
    );
    final summaries = await summariesFuture;
    final parentAssessments = await parentAssessmentsFuture;

    if (!mounted || requestId != _childLoadRequestId) {
      return;
    }
    setState(() {
      _isLoading = false;
      _hasLoadedHome = true;
      _childSummaries = summaries;
      _completedAssessments = parentAssessments;
      _errorMessage = hadError
          ? context.readText(AppKeys.parentChildDashboardLoadFailed)
          : null;
    });
    widget.args.onParentAssessmentStateChanged(
      parentAssessments.isNotEmpty,
    );
  }

  Future<List<GeneratedQuiz>> _loadParentAssessments({
    required VoidCallback onError,
  }) async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.args.activeProfile,
    );
    final userId = widget.args.user?.id;
    if ((profileId == null || profileId <= 0) &&
        (userId == null || userId <= 0)) {
      return const <GeneratedQuiz>[];
    }

    try {
      return await _loadCompletedParentAssessments(
        quizService: widget.args.quizService,
        profileId: profileId,
        userId: userId,
      );
    } catch (_) {
      onError();
      return const <GeneratedQuiz>[];
    }
  }

  Future<void> _loadAssessments() async {
    if (_childSummaries.isNotEmpty) {
      _childSummaries = const <_ParentChildSummary>[];
    }
    final profileId = ActiveProfileSession.profileStableId(
      widget.args.activeProfile,
    );
    final userId = widget.args.user?.id;
    if ((profileId == null || profileId <= 0) &&
        (userId == null || userId <= 0)) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoadedHome = true;
        _errorMessage = null;
        _completedAssessments = const <GeneratedQuiz>[];
      });
      widget.args.onParentAssessmentStateChanged(false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final completed = await _loadCompletedParentAssessments(
        quizService: widget.args.quizService,
        profileId: profileId,
        userId: userId,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasLoadedHome = true;
        _errorMessage = null;
        _completedAssessments = completed;
      });
      widget.args.onParentAssessmentStateChanged(completed.isNotEmpty);
    } on QuizException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoadedHome = true;
        _errorMessage = error.message;
        if (_completedAssessments.isEmpty) {
          _completedAssessments = const <GeneratedQuiz>[];
        }
      });
      widget.args.onParentAssessmentStateChanged(false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoadedHome = true;
        _errorMessage = context.readText(AppKeys.parentQuizLoadFailed);
        if (_completedAssessments.isEmpty) {
          _completedAssessments = const <GeneratedQuiz>[];
        }
      });
      widget.args.onParentAssessmentStateChanged(false);
    }
  }

  Widget _modeOneFadeIn({required Widget child}) {
    if (_hasPlayedModeOneEntrance) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: _homeFadeInDuration,
      curve: Curves.easeOutQuart,
      onEnd: _markModeOneEntrancePlayed,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: Transform.scale(
              scale: 0.985 + 0.015 * value,
              alignment: Alignment.topCenter,
              child: animatedChild,
            ),
          ),
        );
      },
      child: child,
    );
  }

  void _markModeOneEntrancePlayed() {
    if (!mounted || _hasPlayedModeOneEntrance) {
      return;
    }
    setState(() => _hasPlayedModeOneEntrance = true);
  }

  Widget _modeTwoFadeIn({required Widget child}) {
    if (_hasPlayedModeTwoEntrance) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: _homeFadeInDuration,
      curve: Curves.easeOutQuart,
      onEnd: _markModeTwoEntrancePlayed,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: Transform.scale(
              scale: 0.985 + 0.015 * value,
              alignment: Alignment.topCenter,
              child: animatedChild,
            ),
          ),
        );
      },
      child: child,
    );
  }

  void _markModeTwoEntrancePlayed() {
    if (!mounted || _hasPlayedModeTwoEntrance) {
      return;
    }
    setState(() => _hasPlayedModeTwoEntrance = true);
  }

  Widget _modeThreeFadeIn({required Widget child}) {
    if (_hasPlayedModeThreeEntrance) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: _homeFadeInDuration,
      curve: Curves.easeOutQuart,
      onEnd: _markModeThreeEntrancePlayed,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: Transform.scale(
              scale: 0.985 + 0.015 * value,
              alignment: Alignment.topCenter,
              child: animatedChild,
            ),
          ),
        );
      },
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
                child: _ParentLearningStreakCard(
                  hasCompletedAssessment: hasCompletedAssessment,
                ),
              )
            else if (!_isLoading && hasCompletedAssessment)
              _modeTwoFadeIn(
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
      await _loadAssessments();
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

class _ParentChildAssessment {
  const _ParentChildAssessment({
    required this.summary,
    required this.quiz,
  });

  final _ParentChildSummary summary;
  final GeneratedQuiz quiz;
}

class _ParentChildrenGrid extends StatelessWidget {
  const _ParentChildrenGrid({required this.summaries});

  final List<_ParentChildSummary> summaries;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 121,
      ),
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];
        final classroomName = _parentClassroomName(context, summary);
        final teacherName = summary.classroom?.teacherName?.trim();
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          decoration: BoxDecoration(
            color: index.isEven
                ? const Color(0xFFE9F8F6)
                : const Color(0xFFEEF6FD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: index.isEven
                  ? const Color(0xFFC8E4DF)
                  : const Color(0xFFD4E0EC),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                homeProfileDisplayName(context, summary.profile),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: index.isEven
                      ? const Color(0xFF14635E)
                      : const Color(0xFF126696),
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                classroomName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: index.isEven
                      ? const Color(0xFF14635E)
                      : const Color(0xFF126696),
                  fontSize: FontSize.title,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                teacherName?.isNotEmpty == true
                    ? teacherName!
                    : context.getText(AppKeys.parentNoTeacher),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF32625F),
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ParentTeacherMessages extends StatelessWidget {
  const _ParentTeacherMessages({required this.summaries});

  final List<_ParentChildSummary> summaries;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (var index = 0; index < summaries.length; index++) ...[
          _ParentTeacherMessageCard(
            summary: summaries[index],
            index: index,
          ),
          if (index != summaries.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ParentTeacherMessageCard extends StatelessWidget {
  const _ParentTeacherMessageCard({
    required this.summary,
    required this.index,
  });

  final _ParentChildSummary summary;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isFirst = index.isEven;
    final accent = isFirst ? const Color(0xFF17999C) : const Color(0xFFFF701E);
    final surface = isFirst ? const Color(0xFFEFF9F9) : const Color(0xFFFFF2EA);
    final studentName = homeProfileDisplayName(context, summary.profile);
    final classroomName = _parentClassroomName(context, summary);
    final teacherName = summary.classroom?.teacherName?.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  isFirst ? _homeTeacherAvatarOne : _homeTeacherAvatarTwo,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacherName?.isNotEmpty == true
                          ? teacherName!
                          : context.getText(AppKeys.parentNoTeacher),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF001741),
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      classroomName,
                      style: const TextStyle(
                        color: Color(0xFF515F6F),
                        fontSize: FontSize.caption * 0.85,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '10:45 AM',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: FontSize.caption * 0.77,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: accent.withValues(alpha: 0.70),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    studentName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSize.caption * 0.7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.formatText(
                    isFirst
                        ? AppKeys.parentTeacherFeedback
                        : AppKeys.parentTeacherReminder,
                    {'student': studentName},
                  ),
                  style: const TextStyle(
                    color: Color(0xFF30333A),
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w400,
                    height: 1.42,
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
    this.profileName,
    this.classroomName,
  });

  final GeneratedQuiz quiz;
  final VoidCallback onTap;
  final String? profileName;
  final String? classroomName;

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
                    if (profileName != null || classroomName != null) ...[
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (profileName != null)
                            _ParentResultTag(label: profileName!),
                          if (classroomName != null)
                            _ParentResultTag(label: classroomName!),
                        ],
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

class _ParentResultTag extends StatelessWidget {
  const _ParentResultTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF6D5C58),
          fontSize: FontSize.caption * 0.77,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _ParentHomeLoadingCard extends StatelessWidget {
  const _ParentHomeLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 214,
      decoration: BoxDecoration(
        color: const Color(0xFFF1FAF9),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF159A86)),
      ),
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
