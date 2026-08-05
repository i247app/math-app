import 'package:numi/features/quiz/helpers/parent_assessment_quiz_helpers.dart';
import 'package:numi/features/profile/helpers/profile_identity_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/quiz/data/cache/quiz_cache.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/presentation/screens/grade_selection_screen.dart';
import 'package:numi/features/quiz/presentation/screens/learning_progress_screen.dart';
import 'package:numi/features/quiz/presentation/screens/quiz_review_entry_screen.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/quiz/models/parent_assessment_entry.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_progress_chart.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_search_field.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_empty_poster.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_list_skeleton.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_pagination.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_state_card.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_banner.dart';

class ParentAssessmentTab extends StatefulWidget {
  const ParentAssessmentTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.isActive,
    required this.activeRefreshTick,
    required this.initialGrades,
    required this.gradeService,
    required this.quizService,
    required this.bottomPadding,
  });

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final bool isActive;
  final int activeRefreshTick;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final QuizService quizService;
  final double bottomPadding;

  @override
  State<ParentAssessmentTab> createState() => _ParentAssessmentTabState();
}

class _ParentAssessmentTabState extends State<ParentAssessmentTab> {
  static const _pageSize = 5;

  final TextEditingController _searchController = TextEditingController();

  List<ParentAssessmentEntry> _entries = const <ParentAssessmentEntry>[];
  List<ParentAssessmentEntry> _allEntries = const <ParentAssessmentEntry>[];
  QuizPagination? _pagination;
  bool _isLoading = true;
  bool _hasLoaded = false;
  bool _hasPlayedInitialEntrance = false;
  String? _errorMessage;
  int _loadRequestId = 0;
  bool _isActivationLoadScheduled = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    if (widget.isActive) {
      _scheduleActivationLoad();
    }
  }

  @override
  void didUpdateWidget(covariant ParentAssessmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _scheduleActivationLoad();
      return;
    }
    if (!widget.isActive) {
      return;
    }
    if (_profileSourceKey(oldWidget.user, oldWidget.activeProfile) !=
        _profileSourceKey(widget.user, widget.activeProfile)) {
      _pagination = null;
      _allEntries = const <ParentAssessmentEntry>[];
      _hasLoaded = false;
      _loadAssessments(page: 1);
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
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

  void _scheduleActivationLoad() {
    if (_isActivationLoadScheduled) {
      return;
    }

    _isActivationLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isActivationLoadScheduled = false;
      if (!mounted || !widget.isActive) {
        return;
      }
      _loadAssessments();
    });
  }

  String _profileSourceKey(LoginUser? user, StudentProfile? activeProfile) {
    return '${user?.id}|'
        '${ActiveProfileSession.profileStableId(activeProfile)}';
  }

  Future<void> _loadAssessments({bool forceRefresh = false, int? page}) async {
    final requestId = ++_loadRequestId;
    final targetPage = page ?? _pagination?.page ?? 1;
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final userId = widget.user?.id;
    final cachedAssessments = QuizCache.peekList(
      userId: userId,
      profileId: profileId,
    );
    if (!forceRefresh && targetPage == 1 && cachedAssessments != null) {
      setState(() => _applyCachedAssessments(cachedAssessments));
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final entries = <ParentAssessmentEntry>[];
    List<GeneratedQuiz>? loadedAllQuizzes;
    List<ParentAssessmentEntry>? loadedAllEntries;
    QuizPagination? loadedPagination;
    var failed = false;

    if ((profileId != null && profileId > 0) ||
        (userId != null && userId > 0)) {
      try {
        final result = await loadCompletedParentAssessments(
          quizService: widget.quizService,
          profileId: profileId,
          userId: userId,
          page: targetPage,
          size: _pageSize,
        );
        loadedPagination = result.pagination;
        loadedAllQuizzes = result.allQuizzes;
        loadedAllEntries = result.allQuizzes
            .map((quiz) => ParentAssessmentEntry(quiz: quiz))
            .toList(growable: false);
        entries.addAll(
          result.quizzes.map((quiz) => ParentAssessmentEntry(quiz: quiz)),
        );
      } catch (_) {
        failed = true;
      }
    }

    if (!mounted || requestId != _loadRequestId) {
      return;
    }

    entries.sort((a, b) => quizDate(b.quiz).compareTo(quizDate(a.quiz)));
    final pageEntries = entries.take(_pageSize).toList(growable: false);
    setState(() {
      if (!failed || entries.isNotEmpty || _entries.isEmpty) {
        _entries = pageEntries;
        _allEntries = loadedAllEntries ?? pageEntries;
        _pagination = loadedPagination;
      }
      _isLoading = false;
      _hasLoaded = true;
      _errorMessage = failed && _entries.isEmpty
          ? context.readText(AppKeys.parentQuizLoadFailed)
          : null;
    });
    if (!failed && loadedAllQuizzes != null) {
      QuizCache.seedList(
        quizzes: loadedAllQuizzes,
        userId: userId,
        profileId: profileId,
      );
    }
  }

  void _applyCachedAssessments(List<GeneratedQuiz> quizzes) {
    final cachedEntries =
        quizzes
            .map((quiz) => ParentAssessmentEntry(quiz: quiz))
            .toList(growable: false)
          ..sort((a, b) => quizDate(b.quiz).compareTo(quizDate(a.quiz)));
    final totalCount = cachedEntries.length;
    final totalPages = totalCount == 0
        ? 1
        : (totalCount + _pageSize - 1) ~/ _pageSize;
    _entries = cachedEntries.take(_pageSize).toList(growable: false);
    _allEntries = cachedEntries;
    _pagination = QuizPagination(
      page: 1,
      size: _pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
      hasNext: totalPages > 1,
      hasPrevious: false,
    );
    _isLoading = false;
    _hasLoaded = true;
    _errorMessage = null;
  }

  void _selectPage(int page) {
    final totalPages = _pagination?.totalPages ?? 1;
    final currentPage = _pagination?.page ?? 1;
    if (_isLoading || page == currentPage || page < 1 || page > totalPages) {
      return;
    }
    final start = (page - 1) * _pageSize;
    final pageEntries = _allEntries
        .skip(start)
        .take(_pageSize)
        .toList(growable: false);
    setState(() {
      _entries = pageEntries;
      _pagination = QuizPagination(
        page: page,
        size: _pageSize,
        totalCount: _allEntries.length,
        totalPages: totalPages,
        hasNext: page < totalPages,
        hasPrevious: page > 1,
      );
    });
  }

  Widget? _buildPagination({double topPadding = 0}) {
    final pagination = _pagination;
    if (pagination == null ||
        _searchController.text.trim().isNotEmpty ||
        (pagination.totalCount ?? 0) <= 0) {
      return null;
    }

    final currentPage = pagination.page ?? 1;
    final reportedTotalPages = pagination.totalPages ?? 1;
    final totalPages = reportedTotalPages < 1 ? 1 : reportedTotalPages;
    final paginationControl = ParentAssessmentPagination(
      currentPage: currentPage,
      totalPages: totalPages,
      hasPrevious: pagination.hasPrevious ?? currentPage > 1,
      hasNext: pagination.hasNext ?? currentPage < totalPages,
      isLoading: _isLoading,
      onPageSelected: _selectPage,
    );
    return topPadding == 0
        ? paginationControl
        : Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: paginationControl,
          );
  }

  List<ParentAssessmentEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _entries;
    }
    return _allEntries
        .where((entry) {
          final searchable = <String>[
            homeQuizTitle(context, entry.quiz),
            homeQuizDateLabel(entry.quiz),
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

  void _openLearningProgress() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LearningProgressScreen(
          entries: List<ParentAssessmentEntry>.unmodifiable(_allEntries),
        ),
      ),
    );
  }

  Future<void> _openAssessment() async {
    HapticFeedback.lightImpact();
    final assessmentTabRoute = ModalRoute.of(context);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GradeSelectionScreen(
          user: widget.user,
          initialGrades: widget.initialGrades,
          gradeService: widget.gradeService,
          quizPurpose: quizPurposeAssessment,
          profileId: ActiveProfileSession.profileStableId(widget.activeProfile),
          initialGradeId: profileGradeStableId(widget.activeProfile),
          initialGradeLabel: widget.activeProfile?.grade?.label,
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
      await _loadAssessments(forceRefresh: true, page: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final entries = _filteredEntries;
    final shouldShowListSkeleton = _isLoading && _entries.isEmpty;
    final hasNoAssessments =
        _hasLoaded && !_isLoading && _errorMessage == null && _entries.isEmpty;

    final colors = context.themeColors;
    return ColoredBox(
      color: colors.pageBackground,
      child: RefreshIndicator(
        color: colors.brandStrong,
        onRefresh: () => _loadAssessments(forceRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                title: context.getText(AppKeys.parentAssessmentTabTitle),
                topInset: topInset,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                widget.bottomPadding + 20,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _buildAssessmentChildren(
                    entries: entries,
                    hasNoAssessments: hasNoAssessments,
                    shouldShowListSkeleton: shouldShowListSkeleton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAssessmentChildren({
    required List<ParentAssessmentEntry> entries,
    required bool hasNoAssessments,
    required bool shouldShowListSkeleton,
  }) {
    final colors = context.themeColors;
    final shouldShowProgressChart = _allEntries.length > 1;

    if (hasNoAssessments) {
      return [
        _initialFadeIn(
          child: ParentAssessmentEmptyPoster(onTap: _openAssessment),
        ),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: ParentAssessmentTabBanner(onTap: _openAssessment),
      ),
      ParentAssessmentSearchField(controller: _searchController),
      if (shouldShowProgressChart) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
          child: Text(
            context.getText(AppKeys.parentLearningProgress),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        ParentAssessmentProgressChart(
          entries: _allEntries.take(5).toList().reversed.toList(),
          onTap: _openLearningProgress,
        ),
      ],
      if (shouldShowListSkeleton)
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: ParentAssessmentListSkeleton(),
        )
      else if (_errorMessage != null && _entries.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _initialFadeIn(
            child: ParentAssessmentStateCard(
              icon: Icons.cloud_off_rounded,
              title: context.getText(AppKeys.historyLoadErrorTitle),
              message: _errorMessage!,
              onTap: _loadAssessments,
            ),
          ),
        )
      else if (entries.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _initialFadeIn(
            child: Column(
              spacing: 14,
              children: [
                ParentAssessmentStateCard(
                  icon: Icons.assignment_turned_in_outlined,
                  title: context.getText(AppKeys.noHistoryTitle),
                  message: context.getText(AppKeys.noHistoryMessage),
                  onTap: _loadAssessments,
                ),
                ?_buildPagination(),
              ],
            ),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _initialFadeIn(
            child: Column(
              spacing: 14,
              children: [
                ...entries.map(
                  (entry) => AssessmentResultListItemCard(
                    quiz: entry.quiz,
                    onTap: () => _openQuizReview(entry.quiz),
                  ),
                ),
                ?_buildPagination(topPadding: 6),
              ],
            ),
          ),
        ),
    ];
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
