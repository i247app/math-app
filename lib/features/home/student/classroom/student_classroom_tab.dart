part of '../../home_screen.dart';

class _StudentClassroomTab extends StatefulWidget {
  const _StudentClassroomTab({
    required this.bottomPadding,
    required this.scale,
    required this.user,
    required this.activeProfile,
    required this.classroomService,
    required this.isActive,
    this.activeRefreshTick = 0,
  });

  final double bottomPadding;
  final double scale;
  final LoginUser? user;
  final StudentProfile? activeProfile;
  final ClassroomService classroomService;
  final bool isActive;
  final int activeRefreshTick;

  @override
  State<_StudentClassroomTab> createState() => _StudentClassroomTabState();
}

class _StudentClassroomTabState extends State<_StudentClassroomTab> {
  late final ClassroomService _classroomService = widget.classroomService;

  int? get _profileId => ActiveProfileSession.profileStableId(
        widget.activeProfile,
      );

  ClassroomCollectionState get _classroomCollection {
    final profileId = _profileId;
    if (profileId == null || profileId <= 0) {
      return const ClassroomCollectionState(profileId: 0);
    }
    return context.read<ClassroomCubit>().joined(profileId);
  }

  List<ClassroomModel> get _classrooms => _classroomCollection.classrooms;

  bool get _isLoading => _classroomCollection.isLoading;

  bool get _hasLoadedClassrooms => _classroomCollection.hasLoaded;

  String? get _error {
    final profileId = _profileId;
    if (profileId == null || profileId <= 0) {
      return context.readText(AppKeys.studentMissingProfileId);
    }
    return _classroomCollection.errorMessage == null
        ? null
        : context.readText(AppKeys.studentClassroomLoadFailed);
  }

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadClassrooms();
    }
  }

  @override
  void didUpdateWidget(covariant _StudentClassroomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadClassrooms();
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
    if (oldProfileId != profileId) {
      _loadClassrooms();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadClassrooms(forceRefresh: true);
    }
  }

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId = _profileId;
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

  Future<void> _openClassDetail(ClassroomModel classroom) async {
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
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudentClassDetailScreen(
          classroomId: classroomId,
          profileId: profileId,
          initialClassroom: classroom,
          classroomService: _classroomService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = _profileId;
    if (profileId != null && profileId > 0) {
      context.select<ClassroomCubit, ClassroomCollectionState>(
        (cubit) => cubit.joined(profileId),
      );
    }
    final canLoadContent = profileId != null && profileId > 0;
    final isInitialLoading = canLoadContent &&
        _isLoading &&
        _classrooms.isEmpty &&
        !_hasLoadedClassrooms;
    final scale = widget.scale;
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          HomeTabHeader(
            title: context.getText(AppKeys.studentClassroom),
            scale: scale,
            topInset: topInset,
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Visibility(
                    visible: !isInitialLoading,
                    maintainState: true,
                    child: RefreshIndicator(
                      onRefresh: _refreshClassrooms,
                      color: _teal,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          20 * scale,
                          20 * scale,
                          20 * scale,
                          widget.bottomPadding,
                        ),
                        children: [
                          if (_error != null && _classrooms.isEmpty)
                            _StudentInlineErrorPanel(
                              message: _error!,
                              onRetry: _refreshClassrooms,
                            )
                          else if (_classrooms.isEmpty)
                            const _StudentStateCard(
                              titleKey: AppKeys.studentNoClassroomsTitle,
                              messageKey: AppKeys.studentNoClassroomsMessage,
                            )
                          else
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final cardWidth =
                                    (constraints.maxWidth - 10 * scale) / 2;
                                return Wrap(
                                  spacing: 10 * scale,
                                  runSpacing: 12 * scale,
                                  children: [
                                    for (final classroom in _classrooms)
                                      SizedBox(
                                        width: cardWidth,
                                        child: _StudentClassroomTabCard(
                                          classroom: classroom,
                                          onTap: () =>
                                              _openClassDetail(classroom),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          if (_isLoading && _classrooms.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 12 * scale),
                              child: Text(
                                context.getText(AppKeys.loading),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.andika(
                                  color: _muted,
                                  fontSize: FontSize.caption * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          SizedBox(height: 30 * scale),
                          const _StudentJoinAnotherClassroomTitle(),
                          SizedBox(height: 14 * scale),
                          if (canLoadContent)
                            StudentClassSearchContent(
                              profileId: profileId,
                              userId: widget.user?.id,
                              activeRefreshTick: widget.activeRefreshTick,
                              classroomService: _classroomService,
                              onJoinRequested: _refreshClassrooms,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isInitialLoading)
                  const Positioned.fill(
                    child: _StudentClassroomLoadingRegion(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
