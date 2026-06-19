part of '../home_screen.dart';

class ParentAssessmentTab extends StatefulWidget {
  const ParentAssessmentTab({
    super.key,
    required this.args,
  });

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
    _loadAssessments();
  }

  @override
  void didUpdateWidget(covariant ParentAssessmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_profileSourceKey(oldWidget.args) != _profileSourceKey(widget.args)) {
      _loadAssessments();
    } else if (oldWidget.args.activeRefreshTick !=
        widget.args.activeRefreshTick) {
      _loadAssessments();
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

  Future<void> _loadAssessments() async {
    final requestId = ++_loadRequestId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.args.activeProfile,
    );
    final userId = widget.args.user?.id;

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

    entries.sort(
      (a, b) => _quizDate(b.quiz).compareTo(_quizDate(a.quiz)),
    );
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
  }

  List<_ParentAssessmentEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _entries;
    }
    return _entries.where((entry) {
      final searchable = <String>[
        _parentQuizTitle(context, entry.quiz),
        _parentQuizDateLabel(entry.quiz),
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList(growable: false);
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
        onRefresh: _loadAssessments,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: _ParentAssessmentHeader(
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
                  _ParentReviewTabBanner(
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
                            SizedBox(height: 8 * scale),
                          ],
                        ],
                      ),
                    ),
                  if (_isLoading && _entries.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8 * scale),
                      child: Text(
                        context.getText(AppKeys.loading),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.andika(
                          color: const Color(0xFF77859A),
                          fontSize: FontSize.caption * scale,
                          fontWeight: FontWeight.w700,
                        ),
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
      duration: const Duration(milliseconds: 240),
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

class _ParentAssessmentEntry {
  const _ParentAssessmentEntry({
    required this.quiz,
  });

  final GeneratedQuiz quiz;
}

class _ParentAssessmentHeader extends StatelessWidget {
  const _ParentAssessmentHeader({
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
        context.getText(AppKeys.parentAssessmentTabTitle),
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

class _ParentReviewTabBanner extends StatelessWidget {
  const _ParentReviewTabBanner({
    required this.onTap,
    required this.scale,
  });

  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10 * scale);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 3.21,
          child: Image.asset(
            'assets/images/review_tab_banner.jpg',
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              if (frame == null) {
                return _ParentAssessmentSkeletonPulse(
                  builder: (context, color) => _ParentSkeletonBlock(
                    radius: 10 * scale,
                    color: color,
                  ),
                );
              }
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                builder: (context, value, animatedChild) => Opacity(
                  opacity: value,
                  child: animatedChild,
                ),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ParentAssessmentListSkeleton extends StatelessWidget {
  const _ParentAssessmentListSkeleton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _ParentAssessmentSkeletonPulse(
      builder: (context, color) => Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            _ParentSkeletonBlock(
              height: 68 * scale,
              radius: 14 * scale,
              color: color,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                child: Row(
                  children: [
                    _ParentSkeletonBlock(
                      width: 47 * scale,
                      height: 47 * scale,
                      radius: 24 * scale,
                      color: color,
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ParentSkeletonLine(
                            width: 78 * scale,
                            height: 8 * scale,
                            color: color,
                          ),
                          SizedBox(height: 7 * scale),
                          _ParentSkeletonLine(
                            width: 172 * scale,
                            height: 13 * scale,
                            color: color,
                          ),
                          SizedBox(height: 6 * scale),
                          _ParentSkeletonLine(
                            width: 112 * scale,
                            height: 8 * scale,
                            color: color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (index < 2) SizedBox(height: 8 * scale),
          ],
        ],
      ),
    );
  }
}

class _ParentAssessmentSkeletonPulse extends StatefulWidget {
  const _ParentAssessmentSkeletonPulse({required this.builder});

  final Widget Function(BuildContext context, Color color) builder;

  @override
  State<_ParentAssessmentSkeletonPulse> createState() =>
      _ParentAssessmentSkeletonPulseState();
}

class _ParentAssessmentSkeletonPulseState
    extends State<_ParentAssessmentSkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
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
      builder: (context, _) => widget.builder(
        context,
        Color.lerp(
          const Color(0xFFF0F4F3),
          const Color(0xFFDCE7E5),
          _controller.value,
        )!,
      ),
    );
  }
}

class _ParentAssessmentSearchField extends StatelessWidget {
  const _ParentAssessmentSearchField({
    required this.controller,
    required this.scale,
  });

  final TextEditingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFE4DDDF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: const Color(0xFF17252B),
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: context.getText(AppKeys.searchHint),
          hintStyle: TextStyle(
            color: const Color(0xFFD8C5CC),
            fontSize: FontSize.normal * scale,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF063A7B),
            size: 23 * scale,
          ),
          suffixIcon: IconButton(
            onPressed: HapticFeedback.selectionClick,
            icon: Icon(
              Icons.tune_rounded,
              color: const Color(0xFF063A7B),
              size: 21 * scale,
            ),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 11 * scale),
        ),
      ),
    );
  }
}

class _ParentAssessmentProgressChart extends StatelessWidget {
  const _ParentAssessmentProgressChart({
    required this.entries,
    required this.scale,
  });

  final List<_ParentAssessmentEntry> entries;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: const Color(0xFFD7D7D7)),
      ),
      padding: EdgeInsets.fromLTRB(
        5 * scale,
        7 * scale,
        7 * scale,
        4 * scale,
      ),
      child: CustomPaint(
        painter: _ParentAssessmentChartPainter(
          entries: entries,
          scale: scale,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ParentAssessmentChartPainter extends CustomPainter {
  const _ParentAssessmentChartPainter({
    required this.entries,
    required this.scale,
  });

  final List<_ParentAssessmentEntry> entries;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 22 * scale;
    final top = 10 * scale;
    final right = size.width - 5 * scale;
    final bottom = size.height - 18 * scale;
    final chartHeight = bottom - top;
    final chartWidth = right - left;
    final gridPaint = Paint()
      ..color = const Color(0xFFD7E5E4)
      ..strokeWidth = 0.7 * scale;

    for (var index = 0; index <= 5; index++) {
      final y = top + chartHeight * index / 5;
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
      _paintText(
        canvas,
        '${10 - index * 2}',
        Offset(2 * scale, y - 5 * scale),
        color: const Color(0xFF5A676A),
        fontSize: FontSize.caption * 0.54 * scale,
      );
    }

    if (entries.isEmpty) {
      return;
    }

    final points = <Offset>[];
    for (var index = 0; index < entries.length; index++) {
      final score = ((entries[index].quiz.grading?.scorePercentage ?? 0) / 10)
          .clamp(0, 10);
      final x = entries.length == 1
          ? left + chartWidth / 2
          : left + chartWidth * index / (entries.length - 1);
      final y = bottom - chartHeight * score / 10;
      points.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, bottom)
      ..lineTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, bottom)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = const Color(0xFF85D7D2).withValues(alpha: 0.16),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF109B96)
        ..strokeWidth = 1.4 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final score = ((entries[index].quiz.grading?.scorePercentage ?? 0) / 10)
          .clamp(0, 10);
      canvas.drawCircle(
        point,
        2.2 * scale,
        Paint()..color = const Color(0xFF007E79),
      );
      _paintText(
        canvas,
        score.toStringAsFixed(1),
        Offset(point.dx - 6 * scale, point.dy - 12 * scale),
        color: const Color(0xFF007E79),
        fontSize: FontSize.caption * 0.5 * scale,
        fontWeight: FontWeight.w800,
      );
      final date = _quizDate(entries[index].quiz).toLocal();
      final label = date.millisecondsSinceEpoch == 0
          ? '--/--'
          : '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}';
      _paintText(
        canvas,
        label,
        Offset(point.dx - 9 * scale, bottom + 5 * scale),
        color: const Color(0xFF5A676A),
        fontSize: FontSize.caption * 0.5 * scale,
      );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ParentAssessmentChartPainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.scale != scale;
  }
}

class _ParentAssessmentTabCard extends StatelessWidget {
  const _ParentAssessmentTabCard({
    required this.entry,
    required this.scale,
    required this.onTap,
  });

  final _ParentAssessmentEntry entry;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (entry.quiz.grading?.scorePercentage ?? 0).clamp(0, 100);
    final score = (percent / 10).round();
    final scoreColor =
        score >= 8 ? const Color(0xFF087D47) : const Color(0xFFFF6B17);
    final shortText = _parentQuizShortText(entry.quiz);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14 * scale),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 68 * scale),
          padding: EdgeInsets.fromLTRB(
            14 * scale,
            9 * scale,
            11 * scale,
            9 * scale,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: const Color(0xFFE9E4E4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8 * scale,
                offset: Offset(0, 3 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 47 * scale,
                height: 47 * scale,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: math.max(percent / 100, 0.08),
                      strokeWidth: 4.5 * scale,
                      backgroundColor: scoreColor.withValues(alpha: 0.12),
                      color: scoreColor,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: FontSize.title * scale,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: const Color(0xFF575757),
                          size: 14 * scale,
                        ),
                        SizedBox(width: 5 * scale),
                        Text(
                          _parentQuizDateLabel(entry.quiz),
                          style: TextStyle(
                            color: const Color(0xFF575757),
                            fontSize: FontSize.caption * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      _parentQuizTitle(context, entry.quiz),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF17252B),
                        fontSize: FontSize.normal * scale,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    if (shortText != null) ...[
                      SizedBox(height: 3 * scale),
                      Text(
                        shortText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF6D5C58),
                          fontSize: FontSize.small * scale,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF91A7C2),
                size: 22 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentAssessmentStateCard extends StatelessWidget {
  const _ParentAssessmentStateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.onTap,
    required this.scale,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFE1E8E7)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF339395), size: 32 * scale),
          SizedBox(height: 8 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF17252B),
              fontSize: FontSize.normal * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF77859A),
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10 * scale),
          TextButton(
            onPressed: onTap,
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}
