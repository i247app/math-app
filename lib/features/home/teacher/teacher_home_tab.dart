part of '../../classroom/presentation/teacher_classroom_screens.dart';

class TeacherHomeTab extends StatefulWidget {
  const TeacherHomeTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.scale,
    required this.onCompleteProfile,
    this.onOpenClassroomTab,
    ClassroomExerciseService? exerciseService,
    this.activeRefreshTick = 0,
  }) : _exerciseService = exerciseService;

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final double scale;
  final Future<void> Function() onCompleteProfile;
  final VoidCallback? onOpenClassroomTab;
  final int activeRefreshTick;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<TeacherHomeTab> createState() => _TeacherHomeTabState();
}

class _TeacherHomeTabState extends State<TeacherHomeTab> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();

  bool _isLoadingAssignments = false;
  bool _hasLoadedAssignments = false;
  int? _loadedProfileId;
  int _assignmentLoadRequestId = 0;
  List<ClassroomExercise> _recentAssignments = const <ClassroomExercise>[];

  ClassroomCollectionState get _classroomCollection {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId == null || profileId <= 0) {
      return const ClassroomCollectionState(profileId: 0);
    }
    return context.read<ClassroomCubit>().owned(profileId);
  }

  List<ClassroomModel> get _classrooms => _classroomCollection.classrooms;

  bool get _isLoading => _classroomCollection.isLoading;

  bool get _hasLoadedClassrooms => _classroomCollection.hasLoaded;

  String? get _error {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId == null || profileId <= 0) {
      return context.readText(AppKeys.teacherMissingProfileId);
    }
    return _classroomCollection.errorMessage;
  }

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  @override
  void didUpdateWidget(covariant TeacherHomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId != _loadedProfileId) {
      _loadClassrooms();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadClassrooms(forceRefresh: true);
    }
  }

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    final assignmentRequestId = ++_assignmentLoadRequestId;
    if (profileId == null) {
      setState(() {
        _loadedProfileId = profileId;
        _recentAssignments = const <ClassroomExercise>[];
        _isLoadingAssignments = false;
        _hasLoadedAssignments = true;
      });
      return;
    }

    setState(() {
      _isLoadingAssignments = true;
      if (_loadedProfileId != profileId) {
        _recentAssignments = const <ClassroomExercise>[];
        _hasLoadedAssignments = false;
      }
      _loadedProfileId = profileId;
    });

    final collection = await context.read<ClassroomCubit>().loadOwned(
          profileId,
          forceRefresh: forceRefresh,
        );
    if (!mounted || _loadedProfileId != profileId) {
      return;
    }
    final classrooms = collection.classrooms;
    setState(() {
      if (collection.errorMessage == null && classrooms.isEmpty) {
        _recentAssignments = const <ClassroomExercise>[];
      }
      _isLoadingAssignments =
          collection.errorMessage == null && classrooms.isNotEmpty;
      if (collection.errorMessage != null || classrooms.isEmpty) {
        _hasLoadedAssignments = true;
      }
    });
    if (collection.errorMessage != null || classrooms.isEmpty) {
      return;
    }
    unawaited(
      _loadRecentAssignments(
        profileId: profileId,
        classrooms: classrooms,
        requestId: assignmentRequestId,
      ),
    );
  }

  Future<void> _refreshClassrooms() {
    return _loadClassrooms(forceRefresh: true);
  }

  Future<void> _loadRecentAssignments({
    required int profileId,
    required List<ClassroomModel> classrooms,
    required int requestId,
  }) async {
    final classroomIds = classrooms
        .map((classroom) => classroom.stableId)
        .whereType<int>()
        .toList(growable: false);
    if (classroomIds.isEmpty) {
      if (mounted &&
          _loadedProfileId == profileId &&
          _assignmentLoadRequestId == requestId) {
        setState(() {
          _recentAssignments = const <ClassroomExercise>[];
          _isLoadingAssignments = false;
          _hasLoadedAssignments = true;
        });
      }
      return;
    }

    final exerciseGroups = await Future.wait(
      classroomIds.map((classroomId) async {
        try {
          return await _exerciseService.listExercises(
            classroomId: classroomId,
            profileId: profileId,
            purpose: classroomExercisePurposeHomework,
          );
        } catch (_) {
          return const <ClassroomExercise>[];
        }
      }),
    );
    if (!mounted ||
        _loadedProfileId != profileId ||
        _assignmentLoadRequestId != requestId) {
      return;
    }

    final assignments = exerciseGroups
        .expand((exercises) => exercises)
        .toList(growable: false)
      ..sort(_compareRecentAssignments);

    setState(() {
      _recentAssignments = assignments;
      _isLoadingAssignments = false;
      _hasLoadedAssignments = true;
    });
  }

  Future<void> _openCreateClass() async {
    HapticFeedback.lightImpact();
    final previousClassroomIds = _classrooms
        .map((classroom) => classroom.stableId)
        .whereType<int>()
        .toSet();
    final result = await Navigator.of(context).push<_CreateClassResult>(
      MaterialPageRoute(
        builder: (_) => TeacherCreateClassScreen(
          user: widget.user,
          activeProfile: widget.activeProfile,
        ),
      ),
    );
    if (result != null) {
      await _refreshClassrooms();
      if (!mounted) {
        return;
      }
      final classroom = _findCreatedClassroom(result, previousClassroomIds);
      if (classroom != null) {
        await _openClassDetail(classroom, initiallyExpanded: true);
      }
    }
  }

  Future<void> _handleClassCreateAction() async {
    if (!_isTeacherProfileComplete(widget.activeProfile)) {
      HapticFeedback.selectionClick();
      await widget.onCompleteProfile();
      return;
    }

    await _openCreateClass();
  }

  ClassroomModel? _findCreatedClassroom(
    _CreateClassResult result,
    Set<int> previousClassroomIds,
  ) {
    final createdId = result.classroom?.stableId;
    if (createdId != null) {
      for (final classroom in _classrooms) {
        if (classroom.stableId == createdId) {
          return classroom;
        }
      }
      return result.classroom;
    }

    for (final classroom in _classrooms) {
      final id = classroom.stableId;
      if (id != null && !previousClassroomIds.contains(id)) {
        return classroom;
      }
    }
    return null;
  }

  Future<void> _openClassDetail(
    ClassroomModel classroom, {
    bool initiallyExpanded = false,
  }) async {
    final classroomId = classroom.stableId;
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (classroomId == null || profileId == null) {
      _showSnack(context.readText(AppKeys.teacherClassOpenFailed));
      return;
    }

    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TeacherClassDetailScreen(
          classroomId: classroomId,
          profileId: profileId,
          userId: widget.user?.id,
          initialClassroom: classroom,
          initiallyExpanded: initiallyExpanded,
        ),
      ),
    );
  }

  void _openAssignmentDetail(ClassroomExercise exercise) {
    final exerciseId = exercise.stableId;
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (exerciseId == null || profileId == null) {
      _showTeacherHomeworkSoon(context);
      return;
    }

    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherHomeworkDetailScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
          purpose: classroomExercisePurposeHomework,
          exerciseService: _exerciseService,
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId != null && profileId > 0) {
      context.select<ClassroomCubit, ClassroomCollectionState>(
        (cubit) => cubit.owned(profileId),
      );
    }
    final scale = widget.scale;
    final isProfileComplete = _isTeacherProfileComplete(widget.activeProfile);

    return RefreshIndicator(
      color: _teacherTeal,
      onRefresh: _refreshClassrooms,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TeacherTopBar(
              profile: widget.activeProfile,
              topPadding: MediaQuery.paddingOf(context).top,
              scale: scale,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 22 * scale),
                  _TeacherHeroCard(scale: scale),
                  SizedBox(height: 28 * scale),
                  _TeacherClassSectionHeader(
                    scale: scale,
                    hasClasses: _classrooms.isNotEmpty,
                    onAdd: _handleClassCreateAction,
                    onViewAll: widget.onOpenClassroomTab,
                  ),
                  SizedBox(height: 12 * scale),
                  if (_isLoading &&
                      _classrooms.isEmpty &&
                      !_hasLoadedClassrooms)
                    _TeacherLoadingPanel(scale: scale)
                  else if (_error != null && _classrooms.isEmpty)
                    _TeacherErrorPanel(
                      scale: scale,
                      message: _error!,
                      onRetry: _refreshClassrooms,
                    )
                  else if (_classrooms.isEmpty)
                    Column(
                      children: [
                        _TeacherNoClassPanel(
                          scale: scale,
                          isProfileComplete: isProfileComplete,
                          onCreate: _handleClassCreateAction,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _TeacherClassCarousel(
                          scale: scale,
                          classrooms: _classrooms,
                          onOpen: _openClassDetail,
                        ),
                      ],
                    ),
                  SizedBox(height: 30 * scale),
                  _TeacherHomeSectionHeader(
                    scale: scale,
                    title: context.getText(AppKeys.teacherRecentlyAssigned),
                  ),
                  SizedBox(height: 12 * scale),
                  if (_isLoadingAssignments &&
                      _recentAssignments.isEmpty &&
                      !_hasLoadedAssignments)
                    _TeacherAssignmentsLoadingPanel(scale: scale)
                  else if (_recentAssignments.isEmpty)
                    Column(
                      children: [
                        _TeacherEmptyAssignmentsPanel(
                          message: context.getText(
                            AppKeys.teacherNoAssignments,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _TeacherRecentAssignmentCarousel(
                      scale: scale,
                      assignments: _recentAssignments,
                      onOpen: _openAssignmentDetail,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isTeacherProfileComplete(StudentProfile? profile) {
  return profile?.profileStatus?.trim().toUpperCase() == 'OFFICIAL';
}

int _compareRecentAssignments(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = _recentAssignmentSortDate(first);
  final secondDate = _recentAssignmentSortDate(second);
  final firstMs = firstDate?.millisecondsSinceEpoch ?? -1;
  final secondMs = secondDate?.millisecondsSinceEpoch ?? -1;
  final dateCompare = secondMs.compareTo(firstMs);
  if (dateCompare != 0) {
    return dateCompare;
  }
  return (second.stableId ?? -1).compareTo(first.stableId ?? -1);
}

DateTime? _recentAssignmentSortDate(ClassroomExercise exercise) {
  final values = <String?>[
    exercise.createDt,
    exercise.modifyDt,
    exercise.startDate,
    exercise.endDate,
  ];
  for (final value in values) {
    final parsed = DateTime.tryParse(value?.trim() ?? '');
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

class _TeacherTopBar extends StatelessWidget {
  const _TeacherTopBar({
    required this.profile,
    required this.topPadding,
    required this.scale,
  });

  final StudentProfile? profile;
  final double topPadding;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final name = _displayTeacherName(profile);
    return Container(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        topPadding + 16 * scale,
        18 * scale,
        14 * scale,
      ),
      decoration: const BoxDecoration(color: _teacherMint),
      child: Row(
        children: [
          _TeacherAvatar(profile: profile, size: 48 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getText(AppKeys.teacherWelcomeBack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherBlue.withValues(alpha: 0.60),
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    height: 1.25,
                  ),
                ),
                Text(
                  '$name 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherBlue,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x4DC4C6D2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: _teacherBlue,
              size: 22 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherHeroCard extends StatelessWidget {
  const _TeacherHeroCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92 * scale,
      padding:
          EdgeInsets.fromLTRB(14 * scale, 12 * scale, 112 * scale, 18 * scale),
      decoration: BoxDecoration(
        color: _teacherHero,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A002B6A),
            blurRadius: 20 * scale,
            spreadRadius: -4 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -112 * scale,
            bottom: -27 * scale,
            child: Opacity(
              opacity: 0.90,
              child: Image.asset(
                'assets/images/numi-mascot.png',
                width: 118 * scale,
                height: 118 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.getText(AppKeys.teacherHeroTitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: Colors.white,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                context.getText(AppKeys.teacherHeroSubtitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: Colors.white,
                  fontSize: FontSize.small * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeacherClassSectionHeader extends StatelessWidget {
  const _TeacherClassSectionHeader({
    required this.scale,
    required this.hasClasses,
    required this.onAdd,
    this.onViewAll,
  });

  final double scale;
  final bool hasClasses;
  final VoidCallback onAdd;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.getText(AppKeys.teacherYourClasses),
                style: GoogleFonts.andika(
                  color: Colors.black,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                context.getText(AppKeys.viewAllUpper),
                style: GoogleFonts.andika(
                  color: _teacherInk,
                  fontSize: FontSize.small * scale,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
        if (hasClasses) ...[
          SizedBox(height: 8 * scale),
          _SmallCoralAddButton(scale: scale, onTap: onAdd),
        ],
      ],
    );
  }
}

class _TeacherNoClassPanel extends StatelessWidget {
  const _TeacherNoClassPanel({
    required this.scale,
    required this.isProfileComplete,
    required this.onCreate,
  });

  final double scale;
  final bool isProfileComplete;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 383 * scale,
      decoration: const BoxDecoration(color: Color(0xFF308B8D)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 220 * scale,
            height: 220 * scale,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38 * scale),
            ),
            child: Padding(
              padding: EdgeInsets.all(28 * scale),
              child: Image.asset(
                'assets/images/numi-mascot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 22 * scale),
          _CoralCreateButton(
            scale: scale,
            label: context.getText(
              isProfileComplete
                  ? AppKeys.teacherCreateNewClass
                  : AppKeys.teacherCompleteProfile,
            ),
            onTap: onCreate,
          ),
        ],
      ),
    );
  }
}

class _TeacherHomeSectionHeader extends StatelessWidget {
  const _TeacherHomeSectionHeader({
    required this.scale,
    required this.title,
  });

  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: Colors.black,
              fontSize: FontSize.large * scale,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ),
        Text(
          context.getText(AppKeys.viewAllUpper),
          style: GoogleFonts.andika(
            color: _teacherInk,
            fontSize: FontSize.small * scale,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _TeacherClassCarousel extends StatelessWidget {
  const _TeacherClassCarousel({
    required this.scale,
    required this.classrooms,
    required this.onOpen,
  });

  final double scale;
  final List<ClassroomModel> classrooms;
  final ValueChanged<ClassroomModel> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164 * scale,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: classrooms.length,
        separatorBuilder: (_, __) => SizedBox(width: 16 * scale),
        itemBuilder: (context, index) {
          final classroom = classrooms[index];
          return SizedBox(
            width: 166 * scale,
            child: _TeacherClassCard(
              scale: scale,
              classroom: classroom,
              onTap: () => onOpen(classroom),
            ),
          );
        },
      ),
    );
  }
}

class _TeacherAssignmentsLoadingPanel extends StatelessWidget {
  const _TeacherAssignmentsLoadingPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonCarousel(
      scale: scale,
      itemWidth: 178 * scale,
      itemHeight: 164 * scale,
      itemCount: 2,
      builder: (context) => _TeacherAssignmentSkeletonCard(scale: scale),
    );
  }
}

class _TeacherRecentAssignmentCarousel extends StatelessWidget {
  const _TeacherRecentAssignmentCarousel({
    required this.scale,
    required this.assignments,
    required this.onOpen,
  });

  final double scale;
  final List<ClassroomExercise> assignments;
  final ValueChanged<ClassroomExercise> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164 * scale,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: assignments.length,
        separatorBuilder: (_, __) => SizedBox(width: 14 * scale),
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return SizedBox(
            width: 178 * scale,
            child: _TeacherRecentAssignmentCard(
              scale: scale,
              assignment: assignment,
              onTap: () => onOpen(assignment),
            ),
          );
        },
      ),
    );
  }
}

class _TeacherRecentAssignmentCard extends StatelessWidget {
  const _TeacherRecentAssignmentCard({
    required this.scale,
    required this.assignment,
    required this.onTap,
  });

  final double scale;
  final ClassroomExercise assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateParts = _teacherExerciseDateParts(
      assignment.createDt ?? assignment.startDate ?? assignment.endDate,
    );
    final timeLabel = _teacherExerciseDateTimeLabel(
      assignment.createDt ?? assignment.startDate ?? assignment.endDate,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0x33C4C6D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A002B6A),
            blurRadius: 20 * scale,
            spreadRadius: -4 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24 * scale),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(18 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58 * scale,
                  height: 42 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateParts.day,
                        style: GoogleFonts.andika(
                          color: _teacherBlue,
                          fontSize: FontSize.large * scale,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                        ),
                      ),
                      Text(
                        dateParts.month,
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: FontSize.caption * 0.7 * scale,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _teacherExerciseTitle(context, assignment),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherInk,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  timeLabel ??
                      _teacherExerciseQuestionCount(context, assignment),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherMuted,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
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

class _TeacherClassCard extends StatelessWidget {
  const _TeacherClassCard({
    required this.scale,
    required this.classroom,
    required this.onTap,
  });

  final double scale;
  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0x33C4C6D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A002B6A),
            blurRadius: 20 * scale,
            spreadRadius: -4 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24 * scale),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(14 * scale),
            child: Column(
              children: [
                _ClassThumb(classroom: classroom, scale: scale),
                SizedBox(height: 8 * scale),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.andika(
                    color: Colors.black,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Divider(color: const Color(0x1AC4C6D2), height: 4 * scale),
                Text(
                  _teacherMemberSummaryText(
                    context,
                    members: classroom.displayStudentCount,
                    requests: classroom.displayPendingRequestCount,
                  ),
                  maxLines: classroom.displayPendingRequestCount > 0 ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.andika(
                    color: _teacherBlue.withValues(alpha: 0.60),
                    fontSize: FontSize.caption * 0.85 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Container(
                  height: 16 * scale,
                  width: 69 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _teacherDeepTeal,
                    borderRadius: BorderRadius.circular(5 * scale),
                  ),
                  child: Text(
                    context.getText(AppKeys.teacherEnterClass),
                    maxLines: 1,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.caption * 0.85 * scale,
                      fontWeight: FontWeight.w800,
                      height: 1,
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

class _TeacherSkeletonCarousel extends StatelessWidget {
  const _TeacherSkeletonCarousel({
    required this.scale,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemCount,
    required this.builder,
  });

  final double scale;
  final double itemWidth;
  final double itemHeight;
  final int itemCount;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: 16 * scale),
        itemBuilder: (context, index) {
          return SizedBox(
            width: itemWidth,
            child: builder(context),
          );
        },
      ),
    );
  }
}

class _TeacherClassSkeletonCard extends StatelessWidget {
  const _TeacherClassSkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonCard(
      scale: scale,
      padding: EdgeInsets.all(12 * scale),
      child: Column(
        children: [
          _TeacherSkeletonBlock(
            width: 84 * scale,
            height: 56 * scale,
            radius: 16 * scale,
          ),
          SizedBox(height: 8 * scale),
          _TeacherSkeletonBlock(
            width: 72 * scale,
            height: 16 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 8 * scale),
          Divider(color: const Color(0x1AC4C6D2), height: 4 * scale),
          _TeacherSkeletonBlock(
            width: 88 * scale,
            height: 12 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 5 * scale),
          _TeacherSkeletonBlock(
            width: 69 * scale,
            height: 14 * scale,
            radius: 5 * scale,
            color: _teacherTeal.withValues(alpha: 0.20),
          ),
        ],
      ),
    );
  }
}

class _TeacherAssignmentSkeletonCard extends StatelessWidget {
  const _TeacherAssignmentSkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonCard(
      scale: scale,
      padding: EdgeInsets.all(18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeacherSkeletonBlock(
            width: 58 * scale,
            height: 42 * scale,
            radius: 12 * scale,
          ),
          const Spacer(),
          _TeacherSkeletonBlock(
            width: 94 * scale,
            height: 18 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 8 * scale),
          _TeacherSkeletonBlock(
            width: 126 * scale,
            height: 13 * scale,
            radius: 8 * scale,
          ),
        ],
      ),
    );
  }
}

class _TeacherSkeletonCard extends StatelessWidget {
  const _TeacherSkeletonCard({
    required this.scale,
    required this.padding,
    required this.child,
  });

  final double scale;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0x33C4C6D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A002B6A),
            blurRadius: 20 * scale,
            spreadRadius: -4 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _TeacherSkeletonBlock extends StatelessWidget {
  const _TeacherSkeletonBlock({
    required this.width,
    required this.height,
    required this.radius,
    this.color = const Color(0xFFF3F7FA),
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ClassThumb extends StatelessWidget {
  const _ClassThumb({
    required this.classroom,
    required this.scale,
  });

  final ClassroomModel classroom;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        classroom.imageUrl ?? classroom.avatarUrl ?? classroom.fileUrl;
    return Container(
      width: 84 * scale,
      height: 60 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl?.trim().isNotEmpty == true
          ? Image.network(
              imageUrl!.trim(),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _ClassDefaultImage(scale: scale),
            )
          : _ClassDefaultImage(scale: scale),
    );
  }
}

class _ClassDefaultImage extends StatelessWidget {
  const _ClassDefaultImage({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8 * scale),
      child: Image.asset('assets/images/numi-mascot.png', fit: BoxFit.contain),
    );
  }
}

class _TeacherLoadingPanel extends StatelessWidget {
  const _TeacherLoadingPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonCarousel(
      scale: scale,
      itemWidth: 166 * scale,
      itemHeight: 164 * scale,
      itemCount: 2,
      builder: (context) => _TeacherClassSkeletonCard(scale: scale),
    );
  }
}
