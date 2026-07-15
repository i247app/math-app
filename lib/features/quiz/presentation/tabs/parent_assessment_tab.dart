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
import 'package:numi/features/home/data/cache/home_profile_cache.dart';
import 'package:numi/features/home/parent/data/cache/parent_home_snapshot.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/presentation/screens/grade_selection_screen.dart';
import 'package:numi/features/quiz/presentation/screens/quiz_review_entry_screen.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/quiz/models/parent_assessment_entry.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_progress_chart.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_search_field.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_empty_poster.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_full_skeleton.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_state_card.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_practice_tab_banner.dart';

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
    required this.scale,
  });

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final bool isActive;
  final int activeRefreshTick;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final QuizService quizService;
  final double bottomPadding;
  final double scale;

  @override
  State<ParentAssessmentTab> createState() => _ParentAssessmentTabState();
}

class _ParentAssessmentTabState extends State<ParentAssessmentTab> {
  final TextEditingController _searchController = TextEditingController();

  List<ParentAssessmentEntry> _entries = const <ParentAssessmentEntry>[];
  bool _isLoading = true;
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
      _loadAssessments();
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

  Future<void> _loadAssessments({bool forceRefresh = false}) async {
    final requestId = ++_loadRequestId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final userId = widget.user?.id;
    final cache = HomeProfileCache.instance;
    final cachedSnapshot = profileId == null
        ? null
        : cache.getParent(profileId);
    if (!forceRefresh && cachedSnapshot != null) {
      setState(() => _applyCachedAssessments(cachedSnapshot));
      if (!cachedSnapshot.isStale) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final entries = <ParentAssessmentEntry>[];
    var failed = false;

    if ((profileId != null && profileId > 0) ||
        (userId != null && userId > 0)) {
      try {
        final quizzes = await loadCompletedParentAssessments(
          quizService: widget.quizService,
          profileId: profileId,
          userId: userId,
        );
        entries.addAll(
          quizzes.map((quiz) => ParentAssessmentEntry(quiz: quiz)),
        );
      } catch (_) {
        failed = true;
      }
    }

    if (!mounted || requestId != _loadRequestId) {
      return;
    }

    entries.sort((a, b) => quizDate(b.quiz).compareTo(quizDate(a.quiz)));
    setState(() {
      if (!failed || entries.isNotEmpty || _entries.isEmpty) {
        _entries = entries;
      }
      _isLoading = false;
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
            .map((quiz) => ParentAssessmentEntry(quiz: quiz))
            .toList(growable: false)
          ..sort((a, b) => quizDate(b.quiz).compareTo(quizDate(a.quiz)));
    _isLoading = false;
    _errorMessage = null;
  }

  List<ParentAssessmentEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _entries;
    }
    return _entries
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
      await _loadAssessments(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final topInset = MediaQuery.paddingOf(context).top;
    final entries = _filteredEntries;
    final shouldShowFullSkeleton = _isLoading && _entries.isEmpty;
    final hasNoAssessments =
        !_isLoading && _errorMessage == null && _entries.isEmpty;

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
                scale: scale,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                14 * scale,
                16 * scale,
                widget.bottomPadding + 20 * scale,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _buildAssessmentChildren(
                    entries: entries,
                    hasNoAssessments: hasNoAssessments,
                    shouldShowFullSkeleton: shouldShowFullSkeleton,
                    scale: scale,
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
    required bool shouldShowFullSkeleton,
    required double scale,
  }) {
    final colors = context.themeColors;
    final shouldShowProgressChart = _entries.length > 1;

    if (shouldShowFullSkeleton) {
      return [ParentAssessmentFullSkeleton(scale: scale)];
    }

    if (hasNoAssessments) {
      return [
        _initialFadeIn(
          child: ParentAssessmentEmptyPoster(
            onTap: _openAssessment,
            scale: scale,
          ),
        ),
      ];
    }

    return [
      ParentPracticeTabBanner(onTap: _openAssessment, scale: scale),
      SizedBox(height: 13 * scale),
      ParentAssessmentSearchField(controller: _searchController, scale: scale),
      if (shouldShowProgressChart) ...[
        SizedBox(height: 20 * scale),
        Text(
          context.getText(AppKeys.parentLearningProgress),
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: FontSize.large * scale,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8 * scale),
        ParentAssessmentProgressChart(
          entries: _entries.take(5).toList().reversed.toList(),
          scale: scale,
        ),
      ],
      SizedBox(height: 16 * scale),
      if (_errorMessage != null && _entries.isEmpty)
        _initialFadeIn(
          child: ParentAssessmentStateCard(
            icon: Icons.cloud_off_rounded,
            title: context.getText(AppKeys.historyLoadErrorTitle),
            message: _errorMessage!,
            onTap: _loadAssessments,
            scale: scale,
          ),
        )
      else if (entries.isEmpty)
        _initialFadeIn(
          child: ParentAssessmentStateCard(
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
                AssessmentResultListItemCard(
                  quiz: entry.quiz,
                  scale: scale,
                  onTap: () => _openQuizReview(entry.quiz),
                ),
                SizedBox(height: 14 * scale),
              ],
            ],
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
