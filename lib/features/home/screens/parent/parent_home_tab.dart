import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/quiz/models/quiz.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/home/data/home_layout_exception.dart';
import 'package:numi/features/home/helpers/home_layout_helpers.dart';
import 'package:numi/features/home/data/parent_home_snapshot.dart';
import 'package:numi/features/home/widgets/home_missing_student_dialog.dart';
import 'package:numi/features/quiz/data/quiz_snapshot_store.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';
import 'package:numi/features/quiz/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/home/models/parent/parent_child_summary.dart';
import 'package:numi/features/home/helpers/parent_home_helpers.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';
import 'package:numi/features/home/helpers/parent/parent_child_dashboard_helpers.dart';
import 'package:numi/features/home/screens/parent/parent_learning_streak_content.dart';
import 'package:numi/features/home/screens/parent/parent_home_child_dashboard.dart';
import 'package:numi/features/home/screens/parent/parent_home_completed_assessment.dart';
import 'package:numi/features/home/screens/parent/parent_home_first_assessment.dart';
import 'package:numi/features/home/widgets/parent/parent_home_error_card.dart';
import 'package:numi/features/home/widgets/parent/parent_home_loading_card.dart';
import 'package:numi/features/home/widgets/parent/parent_home_refresh_label.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak.dart';
import 'package:numi/features/home/widgets/parent/parent_profile_dialog_action.dart';
import 'package:numi/features/home/widgets/parent/parent_select_student_dialog.dart';

part 'parent_home/snapshot_actions.dart';
part 'parent_home/navigation_actions.dart';

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
    this.showChildProfileDialogOnStart = false,
    this.onChildProfileDialogShown,
    this.homeHeader,
    this.useActiveStudentProfileData = false,
    this.quizSnapshotStore = const NoopQuizSnapshotStore(),
    this.onOpenAssessment,
    this.onOpenQuizReview,
    this.onCreateStudentProfile,
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
  final bool showChildProfileDialogOnStart;
  final VoidCallback? onChildProfileDialogShown;
  final Widget? homeHeader;
  final bool useActiveStudentProfileData;
  final QuizSnapshotStore quizSnapshotStore;
  final Future<void> Function(BuildContext context)? onOpenAssessment;
  final Future<void> Function(BuildContext context, GeneratedQuiz quiz)?
  onOpenQuizReview;
  final Future<void> Function(BuildContext context)? onCreateStudentProfile;

  @override
  State<ParentHomeContent> createState() => ParentHomeContentState();
}

enum ParentHomeEntranceMode {
  initialAssessment,
  completedAssessment,
  childOverview,
}

class ParentHomeContentState extends State<ParentHomeContent> {
  late final HomeLayoutService _homeLayoutService = context
      .read<HomeLayoutService>();
  bool isLoading = true;
  bool hasLoadedHome = false;
  String? errorMessage;
  HomeLayout? homeLayout;
  List<GeneratedQuiz> completedAssessments = const <GeneratedQuiz>[];
  List<ParentChildSummary> childSummaries = const <ParentChildSummary>[];
  int _childLoadRequestId = 0;
  int _assessmentLoadRequestId = 0;
  int _lastAppliedAssessmentLoadRequestId = 0;
  final Set<ParentHomeEntranceMode> _playedEntrances = {};
  bool _hasOfferedMissingStudentProfile = false;
  bool _isMissingStudentDialogVisible = false;

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
    final oldProfileId = profileStableId(oldWidget.activeProfile);
    final profileId = profileStableId(widget.activeProfile);
    final oldChildIds = studentProfiles(
      oldWidget.profiles,
    ).map(profileStableId).join(',');
    final childIds = studentProfiles(
      widget.profiles,
    ).map(profileStableId).join(',');
    final shouldForceRefresh =
        oldWidget.user?.id != widget.user?.id ||
        oldChildIds != childIds ||
        oldWidget.useActiveStudentProfileData !=
            widget.useActiveStudentProfileData;
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
    _playedEntrances.clear();
  }

  List<StudentProfile> get _children {
    if (widget.useActiveStudentProfileData) {
      final profile = homeLayout?.profile ?? widget.activeProfile;
      return profile == null ? const <StudentProfile>[] : [profile];
    }

    final layoutChildren = homeLayout?.parent?.children;
    if (layoutChildren != null &&
        (hasLoadedHome || layoutChildren.isNotEmpty)) {
      return layoutChildren;
    }
    return studentProfiles(widget.profiles);
  }

  Future<void> loadHome({bool forceRefresh = false}) async {
    final requestId = ++_childLoadRequestId;
    final profileId = profileStableId(widget.activeProfile);
    if (profileId == null || profileId <= 0) {
      _assessmentLoadRequestId++;
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

    final assessmentRequestId = _startAssessmentBackgroundRefresh(
      profileId: profileId,
    );

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
      final layoutAssessments = quizzesFromLayoutQuizzes(layout.quizzes);
      final completedAssessments =
          _lastAppliedAssessmentLoadRequestId >= assessmentRequestId
          ? this.completedAssessments
          : layoutAssessments;
      final summaries = widget.useActiveStudentProfileData
          ? _studentSummariesFromLayout(layout, completedAssessments)
          : summariesFromLayout(parent);
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

  int _startAssessmentBackgroundRefresh({required int profileId}) {
    final requestId = ++_assessmentLoadRequestId;
    unawaited(
      _refreshAssessmentsInBackground(
        requestId: requestId,
        profileId: profileId,
      ),
    );
    return requestId;
  }

  Widget homeEntrance({
    required ParentHomeEntranceMode mode,
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_playedEntrances.contains(mode)) {
      return child;
    }

    return AppStaggeredEntrance(
      order: order,
      onFinished: markOnEnd ? () => _markEntrancePlayed(mode) : null,
      child: child,
    );
  }

  void _markEntrancePlayed(ParentHomeEntranceMode mode) {
    if (!mounted || _playedEntrances.contains(mode)) {
      return;
    }
    setState(() => _playedEntrances.add(mode));
  }

  @override
  Widget build(BuildContext context) {
    final hasJoinedClassroom = childSummaries.any(
      (summary) => summary.classroom != null,
    );
    final isInitialChildDashboardLoad =
        _children.isNotEmpty && !hasLoadedHome && isLoading;
    _scheduleMissingStudentDialogIfNeeded();
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
                  if (isLoading && !hasLoadedHome)
                    const LearningStreakSkeleton()
                  else if (!hasCompletedAssessment)
                    homeEntrance(
                      mode: ParentHomeEntranceMode.initialAssessment,
                      order: 0,
                      child: LearningStreakCard(
                        data: parentLearningStreakContent(
                          context,
                          hasCompletedAssessment: hasCompletedAssessment,
                        ),
                      ),
                    )
                  else
                    homeEntrance(
                      mode: ParentHomeEntranceMode.completedAssessment,
                      order: 0,
                      child: LearningStreakCard(
                        data: parentLearningStreakContent(
                          context,
                          hasCompletedAssessment: hasCompletedAssessment,
                        ),
                      ),
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

  void _updateState(VoidCallback update) => setState(update);
}
