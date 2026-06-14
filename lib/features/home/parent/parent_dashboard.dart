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
      return ReviewTab(
        user: args.user,
        activeProfile: args.activeProfile,
        isParentMode: true,
        profileLoadError: args.profileLoadError,
        onRefreshProfiles: args.onRefreshProfiles,
        onAddProfile: args.onAddProfileFromReview,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
      );
    }

    if (args.activeTab == 2) {
      return HistoryTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
      );
    }

    if (args.activeTab == 3) {
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
  String? _errorMessage;
  List<GeneratedQuiz> _completedAssessments = const <GeneratedQuiz>[];

  @override
  void initState() {
    super.initState();
    _loadAssessments();
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
    if (oldProfileId != profileId ||
        oldWidget.args.user?.id != widget.args.user?.id) {
      _loadAssessments();
    }
  }

  Future<void> _loadAssessments() async {
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
      final quizzes = await widget.args.quizService.listQuizzes(
        profileId: profileId != null && profileId > 0 ? profileId : null,
        userId: profileId == null || profileId <= 0 ? userId : null,
      );
      if (!mounted) {
        return;
      }

      final completed = quizzes
          .where(_isCompletedAssessment)
          .toList(growable: false)
        ..sort((a, b) => _quizDate(b).compareTo(_quizDate(a)));
      setState(() {
        _isLoading = false;
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
        _errorMessage = error.message;
        _completedAssessments = const <GeneratedQuiz>[];
      });
      widget.args.onParentAssessmentStateChanged(false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = context.readText(AppKeys.parentQuizLoadFailed);
        _completedAssessments = const <GeneratedQuiz>[];
      });
      widget.args.onParentAssessmentStateChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCompletedAssessment = _completedAssessments.isNotEmpty;
    final padding = EdgeInsets.fromLTRB(
      14 * widget.args.scale,
      widget.args.headerHeight,
      14 * widget.args.scale,
      widget.args.bottomPadding,
    );

    return RefreshIndicator(
      color: const Color(0xFF159A86),
      onRefresh: _loadAssessments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ParentLearningStreakCard(
              hasCompletedAssessment: hasCompletedAssessment,
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const _ParentHomeLoadingCard()
            else if (hasCompletedAssessment)
              _buildCompletedState()
            else
              _buildFirstAssessmentState(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              _ParentHomeErrorCard(
                message: _errorMessage!,
                onRetry: _loadAssessments,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFirstAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StudentFigmaHeroCard(
          onAssessmentTap: _openAssessment,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ParentImageAction(
                asset: _parentHomeAfterReviewBanner,
                height: 160,
                alignment: Alignment.centerLeft,
                onTap: widget.args.onOpenReviewTab,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ParentImageAction(
                asset: _parentHomeClassroom,
                height: 160,
                onTap: _showClassroomMessage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ParentStartGuideCard(
          onAssessmentTap: _openAssessment,
          onRoadmapTap: widget.args.onOpenReviewTab,
          onClassroomTap: _showClassroomMessage,
        ),
      ],
    );
  }

  Widget _buildCompletedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ParentImageAction(
          asset: _parentHomeAfterReviewBanner,
          height: 214,
          onTap: widget.args.onOpenReviewTab,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _ParentImageAction(
                    asset: _parentHomeRace,
                    height: 83,
                    onTap: widget.args.onOpenReviewTab,
                  ),
                  const SizedBox(height: 7),
                  _ParentImageAction(
                    asset: _parentHomeShop,
                    height: 72,
                    onTap: widget.args.onOpenReviewTab,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ParentImageAction(
                asset: _parentHomeClassroom,
                height: 162,
                onTap: _showClassroomMessage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final quiz in _completedAssessments.take(2)) ...[
          _ParentAssessmentResultCard(
            quiz: quiz,
            onTap: () => _openQuizReview(quiz),
          ),
          const SizedBox(height: 8),
        ],
      ],
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

  void _showClassroomMessage() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            context.readText(AppKeys.studentJoinClassroomSoon),
          ),
          behavior: SnackBarBehavior.floating,
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
              fontSize: 14,
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
            fontSize: 10,
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
                      fontSize: 12,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6D5C5C),
                    fontSize: 13,
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
                          fontSize: 26,
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
                            fontSize: 13,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
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
                fontSize: 12,
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
