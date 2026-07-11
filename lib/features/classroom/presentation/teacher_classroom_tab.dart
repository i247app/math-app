part of 'teacher_classroom_screens.dart';

class TeacherClassroomTab extends StatefulWidget {
  const TeacherClassroomTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.scale,
    this.activeRefreshTick = 0,
    this.isActive = true,
  });

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final double scale;
  final int activeRefreshTick;
  final bool isActive;

  @override
  State<TeacherClassroomTab> createState() => _TeacherClassroomTabState();
}

class _TeacherClassroomTabState extends State<TeacherClassroomTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasPlayedClassroomEntrance = false;

  int? get _profileId =>
      ActiveProfileSession.profileStableId(widget.activeProfile);

  ClassroomCollectionState get _classroomCollection {
    final profileId = _profileId;
    if (profileId == null || profileId <= 0) {
      return const ClassroomCollectionState(profileId: 0);
    }
    return context.read<ClassroomCubit>().owned(profileId);
  }

  List<ClassroomModel> get _classrooms => _classroomCollection.classrooms;

  bool get _isLoading => _classroomCollection.isLoading;

  bool get _hasLoadedClassrooms => _classroomCollection.hasLoaded;

  String? get _error {
    final profileId = _profileId;
    if (profileId == null || profileId <= 0) {
      return context.readText(AppKeys.teacherMissingProfileId);
    }
    return _classroomCollection.errorMessage;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadClassrooms();
    }
  }

  @override
  void didUpdateWidget(covariant TeacherClassroomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadClassrooms(forceRefresh: true);
      return;
    }
    if (!widget.isActive) {
      return;
    }
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    if (_profileId != oldProfileId) {
      _hasPlayedClassroomEntrance = false;
      _loadClassrooms();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadClassrooms(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId = _profileId;
    if (profileId == null || profileId <= 0) {
      return;
    }
    await context.read<ClassroomCubit>().loadOwned(
      profileId,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _refreshClassrooms() {
    return _loadClassrooms(forceRefresh: true);
  }

  Widget _teacherClassroomEntrance({
    required int order,
    required Widget child,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedClassroomEntrance) {
      return child;
    }

    return _TeacherClassroomEntrance(
      order: order,
      onFinished: markOnEnd ? _markClassroomEntrancePlayed : null,
      child: child,
    );
  }

  void _markClassroomEntrancePlayed() {
    if (!mounted || _hasPlayedClassroomEntrance) {
      return;
    }
    setState(() => _hasPlayedClassroomEntrance = true);
  }

  Future<void> _openCreateClass() async {
    HapticFeedback.lightImpact();
    final previousClassroomIds = _classrooms
        .map((classroom) => classroom.stableId)
        .whereType<int>()
        .toSet();
    final classroomCubit = context.read<ClassroomCubit>();
    final result = await Navigator.of(context).push<TeacherCreateClassResult>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: classroomCubit,
          child: TeacherCreateClassScreen(
            user: widget.user,
            activeProfile: widget.activeProfile,
          ),
        ),
      ),
    );
    if (result != null) {
      await _refreshClassrooms();
      if (!mounted) {
        return;
      }
      final classroom = _createdClassroomFromResult(
        result,
        previousClassroomIds,
      );
      if (classroom != null) {
        await _openClassDetail(classroom, initiallyExpanded: true);
      }
    }
  }

  ClassroomModel? _createdClassroomFromResult(
    TeacherCreateClassResult result,
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
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (classroomId == null || profileId == null) {
      context.showErrorDialog(context.readText(AppKeys.teacherClassOpenFailed));
      return;
    }

    HapticFeedback.selectionClick();
    final classroomCubit = context.read<ClassroomCubit>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: classroomCubit,
          child: TeacherClassDetailScreen(
            classroomId: classroomId,
            profileId: profileId,
            userId: widget.user?.id,
            initialClassroom: classroom,
            initiallyExpanded: initiallyExpanded,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = _profileId;
    if (profileId != null && profileId > 0) {
      context.select<ClassroomCubit, ClassroomCollectionState>(
        (cubit) => cubit.owned(profileId),
      );
    }
    final scale = widget.scale;
    final displayedClassrooms = _classrooms;
    final isInitialLoading =
        _isLoading && _classrooms.isEmpty && !_hasLoadedClassrooms;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TeacherClassroomHeader(scale: scale),
          Padding(
            padding: EdgeInsets.fromLTRB(
              22 * scale,
              28 * scale,
              22 * scale,
              widget.bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16 * scale),
                if (isInitialLoading)
                  _TeacherClassroomLoadingContent(scale: scale)
                else
                  _TeacherClassroomBody(
                    scale: scale,
                    error: _error,
                    classrooms: _classrooms,
                    displayedClassrooms: displayedClassrooms,
                    searchController: _searchController,
                    entranceBuilder: (order, child, markOnEnd) =>
                        _teacherClassroomEntrance(
                          order: order,
                          child: child,
                          markOnEnd: markOnEnd,
                        ),
                    onCreateClass: _openCreateClass,
                    onOpenClassDetail: _openClassDetail,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
