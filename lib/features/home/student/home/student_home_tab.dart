part of '../../home_screen.dart';

class _StudentHomeContent extends StatefulWidget {
  const _StudentHomeContent({
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
    required this.onOpenReviewTab,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.onProfileSaved,
    required this.parentHomeEntrance,
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
  final VoidCallback onOpenReviewTab;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final VoidCallback onProfileSaved;
  final Animation<double> parentHomeEntrance;
  final int activeRefreshTick;

  @override
  State<_StudentHomeContent> createState() => _StudentHomeContentState();
}

class _StudentHomeContentState extends State<_StudentHomeContent> {
  late final ClassroomService _classroomService = widget.classroomService;
  late final ClassroomExerciseService _assignmentService =
      widget.assignmentService;
  late final HomeLayoutService _homeLayoutService = HomeLayoutApi();
  final _StudentHomePanel _activePanel = _StudentHomePanel.homework;
  bool _isLoadingInvitations = false;
  bool _isLoadingAssessments = false;
  bool _isLoadingHomeLayout = false;
  bool _hasLoadedHomeLayout = false;
  bool _isLoadingModeHomework = false;
  bool _hasPlayedInitialAssessmentEntrance = false;
  bool _hasPlayedCompletedAssessmentEntrance = false;
  bool _hasPlayedClassroomOverviewEntrance = false;
  List<ClassroomInvitation> _invitations = const <ClassroomInvitation>[];
  List<GeneratedQuiz> _completedAssessments = const <GeneratedQuiz>[];
  List<ClassroomModel> _layoutClassrooms = const <ClassroomModel>[];
  List<ClassroomExercise> _modeHomeworkExercises = const <ClassroomExercise>[];
  final Set<int> _processingInvitationClassIds = <int>{};
  int? _modeHomeworkClassroomId;
  int? _modeHomeworkProfileId;
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

  bool get _isLoadingClassrooms => _classroomCollection.isLoading;

  // ignore: unused_element
  bool get _hasLoadedClassrooms => _classroomCollection.hasLoaded;

  String? get _classroomError => _classroomCollection.errorMessage == null
      ? null
      : context.readText(AppKeys.studentClassroomLoadFailed);

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadHomeLayout();
    }
  }

  @override
  void didUpdateWidget(covariant _StudentHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadHomeLayout(forceRefresh: true);
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
      _invitations = const <ClassroomInvitation>[];
      _isLoadingAssessments = false;
      _completedAssessments = const <GeneratedQuiz>[];
      _isLoadingHomeLayout = false;
      _hasLoadedHomeLayout = false;
      _layoutClassrooms = const <ClassroomModel>[];
      _isLoadingModeHomework = false;
      _modeHomeworkExercises = const <ClassroomExercise>[];
      _modeHomeworkClassroomId = null;
      _modeHomeworkProfileId = null;
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
      final layout = await _homeLayoutService.getLayout(profileId: profileId);
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
        _modeHomeworkClassroomId = classrooms.isEmpty
            ? null
            : classrooms.first.stableId;
        _modeHomeworkProfileId = profileId;
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

  void _applySnapshot(StudentHomeSnapshot snapshot) {
    _isLoadingHomeLayout = false;
    _hasLoadedHomeLayout = true;
    _layoutClassrooms = snapshot.layoutClassrooms;
    _modeHomeworkExercises = snapshot.modeHomeworkExercises;
    _modeHomeworkClassroomId = snapshot.layoutClassrooms.isEmpty
        ? null
        : snapshot.layoutClassrooms.first.stableId;
    _modeHomeworkProfileId = snapshot.profileId;
    _isLoadingModeHomework = false;
    _completedAssessments = snapshot.completedAssessments;
  }

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      return;
    }
    await context.read<ClassroomCubit>().loadJoined(
      profileId,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _refreshClassrooms() {
    return _loadClassrooms(forceRefresh: true);
  }

  Future<void> _loadInvitations() async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0 || _isLoadingInvitations) {
      return;
    }

    setState(() {
      _isLoadingInvitations = true;
    });

    try {
      final invitations = await _classroomService.listMyPendingInvitations(
        profileId: profileId,
      );
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }

      setState(() {
        _invitations = invitations;
      });
    } catch (_) {
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }

      setState(() {
        _invitations = const <ClassroomInvitation>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingInvitations = false);
      } else {
        _isLoadingInvitations = false;
      }
    }
  }

  // ignore: unused_element
  Future<void> _loadAssessments() async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final userId = widget.user?.id;
    if (_isLoadingAssessments ||
        ((profileId == null || profileId <= 0) &&
            (userId == null || userId <= 0))) {
      return;
    }

    setState(() => _isLoadingAssessments = true);
    try {
      final quizzes = await widget.quizService.listQuizzes(
        profileId: profileId,
        userId: userId,
      );
      if (!mounted) {
        return;
      }
      if (ActiveProfileSession.profileStableId(widget.activeProfile) !=
          profileId) {
        setState(() => _isLoadingAssessments = false);
        if (widget.isActive) {
          await _loadAssessments();
        }
        return;
      }
      final completed = quizzes.where(_isCompletedAssessment).toList()
        ..sort((a, b) => _quizDate(b).compareTo(_quizDate(a)));
      setState(() {
        _completedAssessments = completed;
        _isLoadingAssessments = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _completedAssessments = const <GeneratedQuiz>[];
        _isLoadingAssessments = false;
      });
    }
  }

  // ignore: unused_element
  Future<void> _loadModeHomework({
    required int classroomId,
    required int profileId,
  }) async {
    if (_isLoadingModeHomework &&
        _modeHomeworkClassroomId == classroomId &&
        _modeHomeworkProfileId == profileId) {
      return;
    }

    setState(() {
      _isLoadingModeHomework = true;
      _modeHomeworkClassroomId = classroomId;
      _modeHomeworkProfileId = profileId;
    });

    try {
      final exercises = await _assignmentService.listExercises(
        classroomId: classroomId,
        profileId: profileId,
      );
      if (!mounted ||
          _modeHomeworkClassroomId != classroomId ||
          _modeHomeworkProfileId != profileId) {
        return;
      }
      exercises.sort(
        (a, b) => _studentModeDate(
          b.createDt ?? b.startDate ?? b.endDate,
        ).compareTo(_studentModeDate(a.createDt ?? a.startDate ?? a.endDate)),
      );
      setState(() {
        _modeHomeworkExercises = exercises;
        _isLoadingModeHomework = false;
      });
    } catch (_) {
      if (!mounted ||
          _modeHomeworkClassroomId != classroomId ||
          _modeHomeworkProfileId != profileId) {
        return;
      }
      setState(() {
        _modeHomeworkExercises = const <ClassroomExercise>[];
        _isLoadingModeHomework = false;
      });
    }
  }

  // ignore: unused_element
  Future<void> _handleInvitation(
    ClassroomInvitation invitation, {
    required bool accept,
  }) async {
    if (!await _allowClassroomActionForActiveRole()) {
      return;
    }

    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final classroomId = invitation.stableClassroomId;
    if (profileId == null || profileId <= 0 || classroomId == null) {
      return;
    }
    final inviterProfileId = invitation.inviterProfileId ?? profileId;

    setState(() => _processingInvitationClassIds.add(classroomId));
    try {
      if (accept) {
        await _classroomService.acceptInvitation(
          inviteeProfileId: profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
      } else {
        await _classroomService.rejectInvitation(
          inviteeProfileId: profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.readText(
                accept
                    ? AppKeys.studentInvitationAcceptSuccess
                    : AppKeys.studentInvitationRejectSuccess,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      await _loadInvitations();
      if (accept) {
        await _loadClassrooms(forceRefresh: true);
      }
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _processingInvitationClassIds.remove(classroomId));
      }
    }
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

    return _ParentHomeEntrance(
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

    return _StudentClassroomOverviewEntrance(
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: widget.padding,
      child: widget.activeRole == ProfileRole.parent
          ? _buildStudentInitialAssessmentState()
          : isLoadingHomeSections
          ? const _StudentHomeSectionsLoading()
          : hasClassroom
          ? _buildStudentClassroomOverviewState()
          : hasCompletedAssessment
          ? _buildStudentCompletedAssessmentState()
          : _buildStudentInitialAssessmentState(),
    );
  }

  // ignore: unused_element
  Widget _buildPanel(BuildContext context) {
    return switch (_activePanel) {
      _StudentHomePanel.homework => _StudentHomeworkPanel(
        key: const ValueKey(_StudentHomePanel.homework),
        scale: widget.scale,
      ),
      _StudentHomePanel.classroom => _StudentClassroomPanel(
        key: const ValueKey(_StudentHomePanel.classroom),
        scale: widget.scale,
        classrooms: _classrooms,
        isLoading: _isLoadingClassrooms,
        error: _classroomError,
        onRetry: _refreshClassrooms,
        onJoinClassroom: widget.activeRole == ProfileRole.student
            ? widget.onOpenClassroomTab
            : _handleParentClassroomEntry,
      ),
      _StudentHomePanel.achievement => _StudentAchievementPanel(
        key: const ValueKey(_StudentHomePanel.achievement),
        scale: widget.scale,
      ),
    };
  }

  Future<void> _handleParentClassroomEntry() async {
    await _allowClassroomActionForActiveRole();
  }

  // ignore: unused_element
  Future<void> _openAllInvitations() async {
    if (!await _allowClassroomActionForActiveRole()) {
      return;
    }
    if (!mounted) {
      return;
    }

    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.studentMissingProfileId)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    final acceptedInvitation = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _StudentInvitationListScreen(
          profileId: profileId,
          classroomService: _classroomService,
          initialInvitations: _invitations,
        ),
      ),
    );
    await _loadInvitations();
    if (acceptedInvitation == true) {
      await _loadClassrooms(forceRefresh: true);
    }
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
          color: Colors.white,
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
          color: Colors.white,
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
            style: const TextStyle(
              color: Color(0xFF001741),
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          content: Text(
            context.getText(AppKeys.parentSwitchStudentMessage),
            style: const TextStyle(
              color: Color(0xFF444650),
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
                backgroundColor: const Color(0xFF008080),
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
      barrierColor: const Color(0xFF001741).withValues(alpha: 0.40),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.teacherClassOpenFailed)),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
}
