import 'package:numi/features/profile/helpers/profile_identity_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/home/data/cache/home_profile_cache.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/home/data/home_layout_mappers.dart';
import 'package:numi/features/home/parent/data/cache/parent_home_snapshot.dart';
import 'package:numi/features/home/widgets/home_missing_student_dialog.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/presentation/screens/grade_selection_screen.dart';
import 'package:numi/features/quiz/presentation/screens/quiz_review_entry_screen.dart';
import 'package:numi/features/settings/application/setting_tab.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/shared/parent_home_helpers.dart';
import 'package:numi/shared/widgets/app_staggered_entrance.dart';
import 'package:numi/features/home/parent/home/helpers/parent_child_dashboard_helpers.dart';
import 'package:numi/features/home/parent/home/parent_home_child_dashboard.dart';
import 'package:numi/features/home/parent/home/parent_home_completed_assessment.dart';
import 'package:numi/features/home/parent/home/parent_home_first_assessment.dart';
import 'package:numi/features/home/parent/home/widgets/parent_home_error_card.dart';
import 'package:numi/features/home/parent/home/widgets/parent_home_loading_card.dart';
import 'package:numi/features/home/parent/home/widgets/parent_home_refresh_label.dart';
import 'package:numi/features/home/parent/home/widgets/parent_learning_streak_card.dart';
import 'package:numi/features/home/parent/home/widgets/parent_profile_dialog_action.dart';
import 'package:numi/features/home/parent/home/widgets/parent_select_student_dialog.dart';

class ParentHomeContent extends StatefulWidget {
  const ParentHomeContent({
    super.key,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.isActive,
    required this.activeRefreshTick,
    required this.initialGrades,
    required this.gradeService,
    required this.quizService,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.onProfileSaved,
    required this.onOpenProfileMenu,
    required this.onOpenClassroomTab,
    required this.onOpenPracticeTab,
    required this.onParentAssessmentStateChanged,
    required this.bottomPadding,
    this.homeHeader,
  });

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final bool isActive;
  final int activeRefreshTick;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final QuizService quizService;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final VoidCallback onProfileSaved;
  final VoidCallback onOpenProfileMenu;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenPracticeTab;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final double bottomPadding;
  final Widget? homeHeader;

  @override
  State<ParentHomeContent> createState() => ParentHomeContentState();
}

class ParentHomeContentState extends State<ParentHomeContent> {
  late final HomeLayoutService _homeLayoutService = HomeLayoutApi();
  bool isLoading = true;
  bool hasLoadedHome = false;
  String? errorMessage;
  HomeLayout? homeLayout;
  List<GeneratedQuiz> completedAssessments = const <GeneratedQuiz>[];
  List<ParentChildSummary> childSummaries = const <ParentChildSummary>[];
  int _childLoadRequestId = 0;
  bool _hasPlayedInitialAssessmentEntrance = false;
  bool _hasPlayedCompletedAssessmentEntrance = false;
  bool _hasPlayedClassroomOverviewEntrance = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      loadHome();
    }
  }

  @override
  void didUpdateWidget(covariant ParentHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final oldChildIds = studentProfiles(
      oldWidget.profiles,
    ).map(ActiveProfileSession.profileStableId).join(',');
    final childIds = studentProfiles(
      widget.profiles,
    ).map(ActiveProfileSession.profileStableId).join(',');
    final shouldForceRefresh =
        oldWidget.user?.id != widget.user?.id || oldChildIds != childIds;
    if (oldProfileId != profileId || shouldForceRefresh) {
      hasLoadedHome = false;
      _resetModeEntrances();
      if (widget.isActive) {
        loadHome(forceRefresh: shouldForceRefresh);
      }
      return;
    }
    if (!oldWidget.isActive && widget.isActive) {
      loadHome();
      return;
    }
    if (!widget.isActive) {
      return;
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      loadHome(forceRefresh: true);
    }
  }

  void _resetModeEntrances() {
    _hasPlayedInitialAssessmentEntrance = false;
    _hasPlayedCompletedAssessmentEntrance = false;
    _hasPlayedClassroomOverviewEntrance = false;
  }

  List<StudentProfile> get _children {
    final layoutChildren = homeLayout?.parent?.children;
    if (layoutChildren != null &&
        (hasLoadedHome || layoutChildren.isNotEmpty)) {
      return layoutChildren;
    }
    return studentProfiles(widget.profiles);
  }

  Future<void> loadHome({bool forceRefresh = false}) async {
    final requestId = ++_childLoadRequestId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
        hasLoadedHome = true;
        errorMessage = null;
        homeLayout = null;
        childSummaries = const <ParentChildSummary>[];
        completedAssessments = const <GeneratedQuiz>[];
      });
      widget.onParentAssessmentStateChanged(false);
      return;
    }

    final cache = HomeProfileCache.instance;
    final cachedSnapshot = cache.getParent(profileId);
    if (!forceRefresh && cachedSnapshot != null) {
      setState(() => _applySnapshot(cachedSnapshot));
      widget.onParentAssessmentStateChanged(
        cachedSnapshot.completedAssessments.isNotEmpty,
      );
      if (!cachedSnapshot.isStale) {
        return;
      }
    }

    final hadRenderableContent = hasLoadedHome;
    setState(() {
      isLoading = true;
      errorMessage = null;
      if (!hadRenderableContent) {
        childSummaries = const <ParentChildSummary>[];
        completedAssessments = const <GeneratedQuiz>[];
      }
    });
    if (!hadRenderableContent) {
      widget.onParentAssessmentStateChanged(false);
    }

    try {
      final layout = await cache.loadLayout(
        profileId: profileId,
        loader: () => _homeLayoutService.getLayout(profileId: profileId),
      );
      if (!mounted || requestId != _childLoadRequestId) {
        return;
      }
      final parent = layout.parent;
      final summaries = summariesFromLayout(parent);
      final completedAssessments = quizzesFromLayoutQuizzes(layout.quizzes);
      setState(() {
        isLoading = false;
        hasLoadedHome = true;
        errorMessage = null;
        homeLayout = layout;
        childSummaries = summaries;
        this.completedAssessments = completedAssessments;
      });
      cache.putParent(
        ParentHomeSnapshot(
          profileId: profileId,
          homeLayout: layout,
          completedAssessments: completedAssessments,
          cachedAt: DateTime.now(),
        ),
      );
      widget.onParentAssessmentStateChanged(completedAssessments.isNotEmpty);
    } on HomeLayoutException catch (error) {
      if (!mounted) {
        return;
      }
      if (hadRenderableContent) {
        setState(() {
          isLoading = false;
          errorMessage = error.message;
        });
        return;
      }
      setState(() {
        isLoading = false;
        hasLoadedHome = true;
        errorMessage = error.message;
        homeLayout = null;
        childSummaries = const <ParentChildSummary>[];
        completedAssessments = const <GeneratedQuiz>[];
      });
      widget.onParentAssessmentStateChanged(false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (hadRenderableContent) {
        setState(() {
          isLoading = false;
          errorMessage = context.readText(
            AppKeys.parentChildDashboardLoadFailed,
          );
        });
        return;
      }
      setState(() {
        isLoading = false;
        hasLoadedHome = true;
        errorMessage = context.readText(AppKeys.parentChildDashboardLoadFailed);
        homeLayout = null;
        childSummaries = const <ParentChildSummary>[];
        completedAssessments = const <GeneratedQuiz>[];
      });
      widget.onParentAssessmentStateChanged(false);
    }
  }

  void _applySnapshot(ParentHomeSnapshot snapshot) {
    final parent = snapshot.homeLayout.parent;
    isLoading = false;
    hasLoadedHome = true;
    errorMessage = null;
    homeLayout = snapshot.homeLayout;
    childSummaries = summariesFromLayout(parent);
    completedAssessments = snapshot.completedAssessments;
  }

  Widget initialAssessmentFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedInitialAssessmentEntrance) {
      return child;
    }

    return AppStaggeredEntrance(
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

  Widget completedAssessmentFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedCompletedAssessmentEntrance) {
      return child;
    }

    return AppStaggeredEntrance(
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

  Widget childOverviewFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedClassroomOverviewEntrance) {
      return child;
    }

    return AppStaggeredEntrance(
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
    final hasJoinedClassroom = childSummaries.any(
      (summary) => summary.classroom != null,
    );
    final isInitialChildDashboardLoad =
        _children.isNotEmpty && !hasLoadedHome && isLoading;
    if (_children.isNotEmpty &&
        (hasJoinedClassroom || isInitialChildDashboardLoad)) {
      return buildChildDashboard();
    }

    final hasCompletedAssessment = completedAssessments.isNotEmpty;
    final padding = EdgeInsets.fromLTRB(14, 0, 14, widget.bottomPadding);

    return RefreshIndicator(
      color: context.themeColors.brandStrong,
      onRefresh: loadHome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.homeHeader != null) widget.homeHeader!,
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isLoading && !hasCompletedAssessment)
                    initialAssessmentFadeIn(
                      order: 0,
                      child: ParentLearningStreakCard(
                        hasCompletedAssessment: hasCompletedAssessment,
                      ),
                    )
                  else if (!isLoading && hasCompletedAssessment)
                    completedAssessmentFadeIn(
                      order: 0,
                      child: ParentLearningStreakCard(
                        hasCompletedAssessment: hasCompletedAssessment,
                      ),
                    )
                  else
                    ParentLearningStreakCard(
                      hasCompletedAssessment: hasCompletedAssessment,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: isLoading && !hasLoadedHome
                        ? const ParentHomeLoadingCard()
                        : hasCompletedAssessment
                        ? buildCompletedState()
                        : buildFirstAssessmentState(),
                  ),
                  if (isLoading && hasLoadedHome)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: ParentHomeRefreshLabel(),
                    ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ParentHomeErrorCard(
                        message: errorMessage!,
                        onRetry: loadHome,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openAssessment() async {
    HapticFeedback.lightImpact();
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
        ),
      ),
    );
    if (mounted) {
      await loadHome();
    }
  }

  void openParentAssessmentResult(GeneratedQuiz quiz) {
    _openQuizReview(quiz);
  }

  void openCompletionResult(HomeLayoutRecentCompletion completion) {
    _openQuizReview(quizFromRecentCompletion(completion));
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

  Future<void> showClassroomMessage() async {
    HapticFeedback.selectionClick();
    if (_children.isEmpty) {
      final shouldCreate = await showDialog<bool>(
        context: context,
        barrierColor: context.themeColors.shadow.withValues(alpha: 0.48),
        builder: (_) => const HomeMissingStudentDialog(),
      );
      if (shouldCreate == true && mounted) {
        await _openCreateStudentProfile();
      }
      return;
    }

    final action = await showDialog<ParentProfileDialogAction>(
      context: context,
      barrierColor: context.themeColors.shadow.withValues(alpha: 0.48),
      builder: (_) => const ParentSelectStudentDialog(),
    );
    if (!mounted) {
      return;
    }
    switch (action) {
      case ParentProfileDialogAction.choose:
        widget.onOpenProfileMenu();
        return;
      case ParentProfileDialogAction.create:
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
          color: context.themeColors.pageBackground,
          child: SafeArea(
            child: SettingTab.page(
              user: widget.user,
              profiles: widget.profiles,
              activeProfile: widget.activeProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: widget.onActivateProfile,
              onRefreshProfiles: widget.onRefreshProfiles,
              onProfileSaved: widget.onProfileSaved,
              bottomPadding: 0,
              initialView: SettingPageView.profile,
              isPushedPage: true,
              openAddProfileOnStart: true,
            ),
          ),
        ),
      ),
    );
    await widget.onRefreshProfiles();
  }
}
