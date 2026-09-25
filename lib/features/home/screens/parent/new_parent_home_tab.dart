import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/exam/models/exam.dart';
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
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/home/models/parent/parent_child_summary.dart';
import 'package:numi/features/home/helpers/parent_home_helpers.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';
import 'package:numi/features/home/helpers/parent/parent_child_dashboard_helpers.dart';
import 'package:numi/features/home/widgets/parent/parent_profile_dialog_action.dart';
import 'package:numi/features/home/widgets/parent/parent_select_student_dialog.dart';
import 'package:numi/features/home/widgets/parent/parent_home_action_button.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_grade_ribbon.dart';

part 'new_parent_home/snapshot_actions.dart';
part 'new_parent_home/navigation_actions.dart';

class NewParentHomeContent extends StatefulWidget {
  const NewParentHomeContent({
    super.key,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.isActive,
    required this.activeRefreshTick,
    required this.initialGrades,
    required this.gradeService,
    required this.examService,
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
    this.onOpenAssessment,
    this.onOpenInitialAssessment,
    this.onOpenExamReview,
    this.onCreateStudentProfile,
  });

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final bool isActive;
  final int activeRefreshTick;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final ExamService examService;
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
  final Future<void> Function(BuildContext context)? onOpenAssessment;
  final Future<void> Function(BuildContext context)? onOpenInitialAssessment;
  final Future<void> Function(BuildContext context, GeneratedExam exam)?
  onOpenExamReview;
  final Future<void> Function(BuildContext context)? onCreateStudentProfile;

  @override
  State<NewParentHomeContent> createState() => NewParentHomeContentState();
}

enum NewParentHomeEntranceMode {
  initialAssessment,
  completedAssessment,
  childOverview,
}

class NewParentHomeContentState extends State<NewParentHomeContent> {
  late final HomeLayoutService _homeLayoutService = context
      .read<HomeLayoutService>();
  bool isLoading = true;
  bool hasLoadedHome = false;
  bool isOpeningInitialAssessment = false;
  String? errorMessage;
  HomeLayout? homeLayout;
  List<GeneratedExam> completedAssessments = const <GeneratedExam>[];
  List<ParentChildSummary> childSummaries = const <ParentChildSummary>[];
  int _childLoadRequestId = 0;
  int _assessmentLoadRequestId = 0;
  int _lastAppliedAssessmentLoadRequestId = 0;
  int _progressLoadRequestId = 0;
  int _currentGrade = 0;
  List<int> _previousGrades = const <int>[];
  List<int> _testNumbers = const <int>[1];
  DateTime? _lastSubmittedAt;
  final Set<NewParentHomeEntranceMode> _playedEntrances = {};
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
  void didUpdateWidget(covariant NewParentHomeContent oldWidget) {
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
      _progressLoadRequestId++;
      _currentGrade = 0;
      _previousGrades = const <int>[];
      _testNumbers = const <int>[1];
      _lastSubmittedAt = null;
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
    if (profileId != null && profileId > 0) {
      unawaited(_loadAssessmentProgress(profileId));
    }
    if (profileId == null || profileId <= 0) {
      _assessmentLoadRequestId++;
      _progressLoadRequestId++;
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
        hasLoadedHome = true;
        errorMessage = null;
        homeLayout = null;
        childSummaries = const <ParentChildSummary>[];
        completedAssessments = const <GeneratedExam>[];
        _currentGrade = 0;
        _previousGrades = const <int>[];
        _testNumbers = const <int>[1];
        _lastSubmittedAt = null;
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
        completedAssessments = const <GeneratedExam>[];
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
      final layoutAssessments = examsFromLayoutExams(layout.exams);
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
        completedAssessments = const <GeneratedExam>[];
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
        completedAssessments = const <GeneratedExam>[];
      });
      widget.onParentAssessmentStateChanged(false);
    }
  }

  Future<void> _loadAssessmentProgress(int profileId) async {
    final requestId = ++_progressLoadRequestId;
    try {
      final toDt = DateTime.now();
      final progress = await widget.examService.getExamProgress(
        profileId: profileId,
        fromDt: toDt.subtract(const Duration(days: 365)),
        toDt: toDt,
      );
      if (!mounted || requestId != _progressLoadRequestId) return;
      final points = progress.series.where((point) {
        final status = point.status?.trim().toUpperCase();
        return point.grade != null &&
            (status == null || status == 'COMPLETE' || status == 'SUBMITTED');
      }).toList()..sort((a, b) => a.sequence.compareTo(b.sequence));
      final grade = points.isEmpty ? 0 : points.last.grade!.clamp(0, 5);
      setState(() {
        _currentGrade = grade;
        _previousGrades = points
            .take(points.length - 1)
            .map((point) => point.grade!.clamp(0, 5))
            .toList(growable: false);
        _testNumbers = points.isEmpty
            ? const <int>[1]
            : points.map((point) => point.sequence).toList(growable: false);
        _lastSubmittedAt = points.isEmpty ? null : points.last.completedDt;
      });
    } catch (_) {
      // Keep the last chart when progress is temporarily unavailable.
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
    required NewParentHomeEntranceMode mode,
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

  void _markEntrancePlayed(NewParentHomeEntranceMode mode) {
    if (!mounted || _playedEntrances.contains(mode)) {
      return;
    }
    setState(() => _playedEntrances.add(mode));
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMissingStudentDialogIfNeeded();
    final padding = EdgeInsets.fromLTRB(14, 14, 14, widget.bottomPadding + 18);

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
                  AssessmentGradeRibbon(currentGrade: _currentGrade),
                  const SizedBox(height: 18),
                  AssessmentProgressionChart(
                    key: const ValueKey('parent-home-progress-chart'),
                    finalGrade: _currentGrade,
                    previousGrades: _previousGrades,
                    testNumbers: _testNumbers,
                    lastSubmittedAt: _lastSubmittedAt,
                    chartHeight: 150,
                  ),
                  const SizedBox(height: 24),
                  ParentHomeActionButton(
                    key: const ValueKey('parent-home-assessment-action'),
                    label: 'Assessment Test',
                    icon: Icons.timer_outlined,
                    onTap: openInitialAssessment,
                  ),
                  const SizedBox(height: 18),
                  ParentHomeActionButton(
                    key: const ValueKey('parent-home-practice-action'),
                    label: 'Learning & Practice',
                    icon: Icons.menu_book_rounded,
                    onTap: widget.onOpenPracticeTab,
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
