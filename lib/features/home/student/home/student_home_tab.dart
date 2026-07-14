import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/classroom/application/classroom_cubit.dart';
import 'package:numi/features/classroom/application/classroom_state.dart';
import 'package:numi/features/homework/homework_api.dart';
import 'package:numi/features/home/cache/home_profile_cache.dart';
import 'package:numi/features/home/home_api.dart';
import 'package:numi/features/home/helpers/home_dashboard_helpers.dart';
import 'package:numi/features/home/student/cache/student_home_snapshot.dart';
import 'package:numi/features/home/widgets/home_missing_student_dialog.dart';
import 'package:numi/features/home/widgets/home_visual_constants.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/presentation/screens/grade_selection_screen.dart';
import 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';
import 'package:numi/features/settings/application/setting_tab.dart';
import 'package:numi/features/home/student/shared/widgets/student_home_sections_loading.dart';
import 'package:numi/features/classroom/presentation/screens/student_class_detail_screen.dart';
import 'package:numi/features/home/shared/widgets/home_entrance_animation.dart';
import 'package:numi/features/home/widgets/home_image_action.dart';
import 'package:numi/features/home/widgets/home_initial_assessment_banner.dart';
import 'package:numi/features/home/widgets/home_start_guide_card.dart';
import 'package:numi/features/home/student/home/widgets/student_class_summary_card.dart';
import 'package:numi/features/home/student/home/widgets/student_homework_preview_card.dart';
import 'package:numi/features/home/student/home/widgets/student_game_suggestions_section.dart';
import 'package:numi/features/home/student/student_home_cubit.dart';
import 'package:numi/features/homework/presentation/student_homework_attempt_screen.dart';
import 'package:numi/features/homework/student_homework_open_guard.dart';
import 'package:numi/features/home/parent/assessment/widgets/parent_assessment_tab_card.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';

class StudentHomeContent extends StatefulWidget {
  const StudentHomeContent({
    super.key,
    required this.padding,
    required this.scale,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.activeRole,
    required this.isActive,
    required this.initialGrades,
    required this.gradeService,
    required this.classroomService,
    required this.assignmentService,
    required this.quizService,
    required this.onOpenClassroomTab,
    required this.onOpenPracticeTab,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.onProfileSaved,
    required this.parentHomeEntrance,
    this.header,
    this.activeRefreshTick = 0,
  });

  final EdgeInsets padding;
  final double scale;
  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final bool isActive;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final ClassroomService classroomService;
  final ClassroomExerciseService assignmentService;
  final QuizService quizService;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenPracticeTab;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final VoidCallback onProfileSaved;
  final Animation<double> parentHomeEntrance;
  final Widget? header;
  final int activeRefreshTick;

  @override
  State<StudentHomeContent> createState() => _StudentHomeContentState();
}

class _StudentHomeContentState extends State<StudentHomeContent> {
  late final ClassroomExerciseService _assignmentService =
      widget.assignmentService;
  late final HomeLayoutService _homeLayoutService = HomeLayoutApi();
  bool _isLoadingHomeLayout = false;
  bool _hasLoadedHomeLayout = false;
  bool _isLoadingModeHomework = false;
  bool _hasPlayedInitialAssessmentEntrance = false;
  bool _hasPlayedCompletedAssessmentEntrance = false;
  bool _hasPlayedClassroomOverviewEntrance = false;
  List<GeneratedQuiz> _completedAssessments = const <GeneratedQuiz>[];
  List<ClassroomModel> _layoutClassrooms = const <ClassroomModel>[];
  List<ClassroomExercise> _modeHomeworkExercises = const <ClassroomExercise>[];
  int _homeLayoutRequestId = 0;

  ClassroomCollectionState get _classroomCollection {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      return const ClassroomCollectionState(profileId: 0);
    }
    return context.read<ClassroomCubit>().joined(profileId);
  }

  List<ClassroomModel> get _classrooms {
    if (_hasLoadedHomeLayout || _layoutClassrooms.isNotEmpty) {
      return _layoutClassrooms;
    }
    return _classroomCollection.classrooms;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadHomeLayout();
    }
  }

  @override
  void didUpdateWidget(covariant StudentHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadHomeLayout();
      return;
    }
    if (!widget.isActive) {
      return;
    }
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final roleChanged = oldWidget.activeRole != widget.activeRole;
    if (oldProfileId != profileId || roleChanged) {
      _completedAssessments = const <GeneratedQuiz>[];
      _isLoadingHomeLayout = false;
      _hasLoadedHomeLayout = false;
      _layoutClassrooms = const <ClassroomModel>[];
      _isLoadingModeHomework = false;
      _modeHomeworkExercises = const <ClassroomExercise>[];
      _hasPlayedInitialAssessmentEntrance = false;
      _hasPlayedCompletedAssessmentEntrance = false;
      _hasPlayedClassroomOverviewEntrance = false;
      _loadHomeLayout();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadHomeLayout(forceRefresh: true);
    }
  }

  Future<void> _loadHomeLayout({bool forceRefresh = false}) async {
    final requestId = ++_homeLayoutRequestId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingHomeLayout = false;
        _hasLoadedHomeLayout = true;
        _layoutClassrooms = const <ClassroomModel>[];
        _modeHomeworkExercises = const <ClassroomExercise>[];
        _completedAssessments = const <GeneratedQuiz>[];
        _isLoadingModeHomework = false;
      });
      return;
    }

    final cache = HomeProfileCache.instance;
    final cachedSnapshot = cache.getStudent(profileId);
    if (!forceRefresh && cachedSnapshot != null) {
      setState(() => _applySnapshot(cachedSnapshot));
      if (!cachedSnapshot.isStale) {
        return;
      }
    }

    final hadRenderableContent = _hasLoadedHomeLayout;
    setState(() {
      _isLoadingHomeLayout = true;
      if (!hadRenderableContent) {
        _layoutClassrooms = const <ClassroomModel>[];
        _modeHomeworkExercises = const <ClassroomExercise>[];
        _completedAssessments = const <GeneratedQuiz>[];
      }
    });

    try {
      final layout = await cache.loadLayout(
        profileId: profileId,
        loader: () => _homeLayoutService.getLayout(profileId: profileId),
      );
      if (!mounted ||
          requestId != _homeLayoutRequestId ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }
      final student = layout.student;
      final classrooms = layout.rooms.isNotEmpty
          ? layout.rooms
                .map((classroom) => classroom.classroom)
                .toList(growable: false)
          : student?.classrooms
                    .map((classroom) => classroom.classroom)
                    .toList(growable: false) ??
                const <ClassroomModel>[];
      final modernPendingExercises = layout.tasks
          .where((task) => task.isPending)
          .map((task) => task.exercise)
          .whereType<ClassroomExercise>()
          .toList(growable: false);
      final pendingExercises = layout.tasks.isNotEmpty
          ? modernPendingExercises
          : student?.pendingExercises
                    .map((pending) => pending.exercise)
                    .whereType<ClassroomExercise>()
                    .toList(growable: false) ??
                const <ClassroomExercise>[];
      setState(() {
        _isLoadingHomeLayout = false;
        _hasLoadedHomeLayout = true;
        _layoutClassrooms = classrooms;
        _modeHomeworkExercises = pendingExercises;
        _isLoadingModeHomework = false;
        _completedAssessments = _quizzesFromLayoutQuizzes(layout.quizzes);
      });
      cache.putStudent(
        StudentHomeSnapshot(
          profileId: profileId,
          layoutClassrooms: classrooms,
          modeHomeworkExercises: pendingExercises,
          completedAssessments: _quizzesFromLayoutQuizzes(layout.quizzes),
          cachedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      if (!mounted || requestId != _homeLayoutRequestId) {
        return;
      }
      if (hadRenderableContent) {
        setState(() {
          _isLoadingHomeLayout = false;
          _isLoadingModeHomework = false;
        });
        return;
      }
      setState(() {
        _isLoadingHomeLayout = false;
        _hasLoadedHomeLayout = true;
        _layoutClassrooms = const <ClassroomModel>[];
        _modeHomeworkExercises = const <ClassroomExercise>[];
        _completedAssessments = const <GeneratedQuiz>[];
        _isLoadingModeHomework = false;
      });
    }
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
    ];
  }

  void _applySnapshot(StudentHomeSnapshot snapshot) {
    _isLoadingHomeLayout = false;
    _hasLoadedHomeLayout = true;
    _layoutClassrooms = snapshot.layoutClassrooms;
    _modeHomeworkExercises = snapshot.modeHomeworkExercises;
    _isLoadingModeHomework = false;
    _completedAssessments = snapshot.completedAssessments;
  }

  Widget _studentHomeEntrance({
    required int order,
    required Widget child,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedInitialAssessmentEntrance &&
        _hasPlayedCompletedAssessmentEntrance &&
        _hasPlayedClassroomOverviewEntrance) {
      return child;
    }

    return HomeEntranceAnimation(
      order: order,
      onFinished: markOnEnd ? _markStudentModeEntrancePlayed : null,
      child: child,
    );
  }

  void _markStudentModeEntrancePlayed() {
    if (!mounted) {
      return;
    }
    setState(() {
      _hasPlayedInitialAssessmentEntrance = true;
      _hasPlayedCompletedAssessmentEntrance = true;
      _hasPlayedClassroomOverviewEntrance = true;
    });
  }

  Widget _studentClassroomOverviewEntrance({
    required int order,
    required Widget child,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedClassroomOverviewEntrance) {
      return child;
    }

    return HomeEntranceAnimation(
      order: order,
      onFinished: markOnEnd
          ? _markStudentClassroomOverviewEntrancePlayed
          : null,
      child: child,
    );
  }

  void _markStudentClassroomOverviewEntrancePlayed() {
    if (!mounted || _hasPlayedClassroomOverviewEntrance) {
      return;
    }
    setState(() => _hasPlayedClassroomOverviewEntrance = true);
  }

  @override
  Widget build(BuildContext context) {
    final isLoadingHomeSections = _isLoadingHomeLayout && !_hasLoadedHomeLayout;
    final hasClassroom =
        widget.activeRole == ProfileRole.student && _classrooms.isNotEmpty;
    final hasCompletedAssessment = _completedAssessments.isNotEmpty;

    final content = widget.activeRole == ProfileRole.parent
        ? _buildStudentInitialAssessmentState()
        : isLoadingHomeSections
        ? const StudentHomeSectionsLoading()
        : hasClassroom
        ? _buildStudentClassroomOverviewState()
        : hasCompletedAssessment
        ? _buildStudentCompletedAssessmentState()
        : _buildStudentInitialAssessmentState();

    return Column(
      children: [
        if (widget.header != null) widget.header!,
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: widget.padding,
            child: content,
          ),
        ),
      ],
    );
  }

  Future<void> _handleParentClassroomEntry() async {
    await _allowClassroomActionForActiveRole();
  }

  Future<bool> _allowClassroomActionForActiveRole() async {
    if (widget.activeRole != ProfileRole.parent) {
      return true;
    }

    if (_studentProfiles.isEmpty) {
      await widget.onRefreshProfiles();
      if (!mounted) {
        return false;
      }
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) {
        return false;
      }
    }

    if (_studentProfiles.isNotEmpty) {
      final shouldSwitch = await _showParentSwitchStudentDialog();
      if (shouldSwitch == true && mounted) {
        await _openProfileSwitch();
      }
      return false;
    }

    final shouldCreateStudent = await _showMissingStudentDialog();
    if (!mounted) {
      return false;
    }
    if (shouldCreateStudent == true) {
      await _openCreateStudentProfile();
    }
    return false;
  }

  List<StudentProfile> get _studentProfiles {
    return widget.profiles
        .where(
          (profile) => ProfileRole.fromProfile(profile) == ProfileRole.student,
        )
        .toList();
  }

  Future<void> _openProfileSwitch() async {
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
              scale: widget.scale,
              initialView: SettingPageView.profile,
              isPushedPage: true,
            ),
          ),
        ),
      ),
    );
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
              scale: widget.scale,
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

  Future<bool?> _showParentSwitchStudentDialog() {
    HapticFeedback.selectionClick();
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            context.getText(AppKeys.parentSwitchStudentTitle),
            style: TextStyle(
              color: context.themeColors.textPrimary,
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          content: Text(
            context.getText(AppKeys.parentSwitchStudentMessage),
            style: TextStyle(
              color: context.themeColors.textSecondary,
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.getText(AppKeys.cancel)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: context.themeColors.brandStrong,
              ),
              child: Text(context.getText(AppKeys.parentSwitchStudentAction)),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showMissingStudentDialog() {
    HapticFeedback.selectionClick();
    return showDialog<bool>(
      context: context,
      barrierColor: context.themeColors.shadow.withValues(alpha: 0.40),
      builder: (_) => const HomeMissingStudentDialog(),
    );
  }

  void _openGradeSelection(String quizPurpose) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GradeSelectionScreen(
          user: widget.user,
          initialGrades: widget.initialGrades,
          gradeService: widget.gradeService,
          quizPurpose: quizPurpose,
          profileId: ActiveProfileSession.profileStableId(widget.activeProfile),
          initialGradeId: profileGradeId(widget.activeProfile),
          initialGradeLabel: widget.activeProfile?.grade?.label,
        ),
      ),
    );
  }

  void _openStudentAssessmentResult(GeneratedQuiz quiz) {
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

  Future<void> _openClassDetail(ClassroomModel classroom) async {
    if (!await _allowClassroomActionForActiveRole()) {
      return;
    }
    if (!mounted) {
      return;
    }

    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final classroomId = classroom.stableId;
    if (profileId == null || profileId <= 0 || classroomId == null) {
      context.showErrorDialog(context.readText(AppKeys.teacherClassOpenFailed));
      return;
    }

    HapticFeedback.selectionClick();
    final classroomCubit = context.read<ClassroomCubit>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: classroomCubit,
          child: StudentClassDetailScreen(
            classroomId: classroomId,
            profileId: profileId,
            initialClassroom: classroom,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInitialAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _studentHomeEntrance(
          order: 0,
          child: HomeInitialAssessmentBanner(
            onTap: () => _openGradeSelection(quizPurposeAssessment),
          ),
        ),
        const SizedBox(height: 8),
        _studentHomeEntrance(
          order: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HomeImageAction(
                  asset: parentHomeAfterReviewBannerAsset,
                  height: 160,
                  alignment: Alignment.centerLeft,
                  onTap: widget.onOpenPracticeTab,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HomeImageAction(
                  asset: parentHomeClassroomAsset,
                  height: 160,
                  onTap: widget.activeRole == ProfileRole.student
                      ? widget.onOpenClassroomTab
                      : _handleParentClassroomEntry,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _studentHomeEntrance(
          order: 2,
          markOnEnd: true,
          child: HomeStartGuideCard(
            onAssessmentTap: () => _openGradeSelection(quizPurposeAssessment),
            onRoadmapTap: widget.onOpenPracticeTab,
            onClassroomTap: widget.onOpenClassroomTab,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCompletedAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _studentHomeEntrance(
          order: 0,
          child: HomeImageAction(
            asset: parentHomeAfterReviewBannerAsset,
            height: 214,
            onTap: widget.onOpenPracticeTab,
          ),
        ),
        const SizedBox(height: 8),
        _studentHomeEntrance(
          order: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    HomeImageAction(
                      asset: parentHomeRaceAsset,
                      height: 83,
                      onTap: widget.onOpenPracticeTab,
                    ),
                    const SizedBox(height: 7),
                    HomeImageAction(
                      asset: parentHomeShopAsset,
                      height: 83,
                      onTap: widget.onOpenPracticeTab,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HomeImageAction(
                  asset: parentHomeClassroomAsset,
                  height: 173,
                  onTap: widget.onOpenClassroomTab,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in _completedAssessments.take(2).indexed) ...[
          _studentHomeEntrance(
            order: 2 + entry.$1,
            markOnEnd:
                entry.$1 == 1 ||
                entry.$1 == _completedAssessments.take(2).length - 1,
            child: AssessmentResultListItemCard(
              quiz: entry.$2,
              scale: widget.scale,
              onTap: () => _openStudentAssessmentResult(entry.$2),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildStudentClassroomOverviewState() {
    final classroom = _classrooms.first;
    final exercises = _modeHomeworkExercises.take(2).toList();
    final previewCount = exercises.isEmpty ? 1 : exercises.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _studentClassroomOverviewEntrance(
          order: 0,
          child: StudentClassSummaryCard(
            classroom: classroom,
            onTap: () => _openClassDetail(classroom),
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoadingModeHomework && exercises.isEmpty)
          const StudentHomeSectionsLoading()
        else ...[
          for (var index = 0; index < previewCount; index++) ...[
            _studentClassroomOverviewEntrance(
              order: 1 + index,
              child: StudentHomeworkPreviewCard(
                exercise: index < exercises.length ? exercises[index] : null,
                classroom: classroom,
                index: index,
                onTap: index < exercises.length
                    ? () => _openModeHomework(exercises[index])
                    : widget.onOpenClassroomTab,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
        _studentClassroomOverviewEntrance(
          order: 3,
          markOnEnd: true,
          child: StudentGameSuggestionsSection(
            onViewAll: () => context.read<StudentHomeCubit>().selectTab(3),
          ),
        ),
      ],
    );
  }

  Future<void> _openModeHomework(ClassroomExercise exercise) async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final exerciseId = exercise.stableId;
    if (profileId == null || profileId <= 0 || exerciseId == null) {
      return;
    }

    if (showStudentHomeworkNotOpenDialogIfNeeded(context, exercise)) {
      return;
    }

    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudentHomeworkAttemptScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
          exerciseService: _assignmentService,
        ),
      ),
    );

    if (mounted) {
      await _loadHomeLayout();
    }
  }
}
