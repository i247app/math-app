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

  int? get _profileId => ActiveProfileSession.profileStableId(
        widget.activeProfile,
      );

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
      _loadClassrooms();
      return;
    }
    if (!widget.isActive) {
      return;
    }
    final oldProfileId =
        ActiveProfileSession.profileStableId(oldWidget.activeProfile);
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
      final createdId = result.classroom?.stableId;
      ClassroomModel? classroom;
      if (createdId != null) {
        for (final c in _classrooms) {
          if (c.stableId == createdId) {
            classroom = c;
            break;
          }
        }
        classroom ??= result.classroom;
      } else {
        for (final c in _classrooms) {
          final id = c.stableId;
          if (id != null && !previousClassroomIds.contains(id)) {
            classroom = c;
            break;
          }
        }
      }

      if (classroom != null) {
        await _openClassDetail(classroom, initiallyExpanded: true);
      }
    }
  }

  Future<void> _openClassDetail(
    ClassroomModel classroom, {
    bool initiallyExpanded = false,
  }) async {
    final classroomId = classroom.stableId;
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (classroomId == null || profileId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(context.readText(AppKeys.teacherClassOpenFailed))));
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

  @override
  Widget build(BuildContext context) {
    final profileId = _profileId;
    if (profileId != null && profileId > 0) {
      context.select<ClassroomCubit, ClassroomCollectionState>(
        (cubit) => cubit.owned(profileId),
      );
    }
    final scale = widget.scale;

    // Filter logic can be added later, for now just show all
    final displayedClassrooms = _classrooms;
    final isInitialLoading =
        _isLoading && _classrooms.isEmpty && !_hasLoadedClassrooms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header (styled like SettingTab)
        Container(
          height: MediaQuery.paddingOf(context).top + 60 * scale,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFF2F2F2),
                width: 4 * scale,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            18 * scale,
            MediaQuery.paddingOf(context).top + 6 * scale,
            18 * scale,
            6 * scale,
          ),
          child: Row(
            children: [
              SizedBox(width: 40 * scale),
              Expanded(
                child: Text(
                  context.getText(AppKeys.studentClassroom), // Lớp Học
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherTeal,
                    fontSize: FontSize.title,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SizedBox(width: 40 * scale),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                else ...[
                  _teacherClassroomEntrance(
                    order: 0,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _openCreateClass,
                        child: Container(
                          width: 90 * scale,
                          height: 36 * scale,
                          decoration: BoxDecoration(
                            color: _teacherCoral,
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24 * scale,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  _teacherClassroomEntrance(
                    order: 1,
                    child: Container(
                      height: 48 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24 * scale),
                        border: Border.all(color: const Color(0xFFE2E9EC)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 16 * scale),
                          Icon(
                            Icons.search,
                            color: _teacherBlue,
                            size: 24 * scale,
                          ),
                          SizedBox(width: 12 * scale),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onTapOutside: (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              style: GoogleFonts.andika(
                                color: _teacherInk,
                                fontSize: FontSize.normal * scale,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: context.getText(
                                  AppKeys.teacherSearchClassroomHint,
                                ),
                                hintStyle: GoogleFonts.andika(
                                  color: _teacherMuted.withValues(alpha: 0.6),
                                  fontSize: FontSize.normal * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.tune,
                            color: _teacherBlue,
                            size: 24 * scale,
                          ),
                          SizedBox(width: 16 * scale),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  if (_error != null && _classrooms.isEmpty)
                    _teacherClassroomEntrance(
                      order: 2,
                      markOnEnd: true,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24 * scale),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.andika(
                              color: _teacherMuted,
                              fontSize: FontSize.small * scale,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (_classrooms.isEmpty)
                    _teacherClassroomEntrance(
                      order: 2,
                      markOnEnd: true,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24 * scale),
                          child: Text(
                            context.getText(
                              AppKeys.teacherEmptyClassroomList,
                            ),
                            style: GoogleFonts.andika(
                              color: _teacherMuted,
                              fontSize: FontSize.normal * scale,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: displayedClassrooms.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16 * scale),
                      itemBuilder: (context, index) {
                        final classroom = displayedClassrooms[index];
                        return _teacherClassroomEntrance(
                          order: 2 + index,
                          markOnEnd: index == displayedClassrooms.length - 1,
                          child: _ClassroomListCard(
                            scale: scale,
                            classroom: classroom,
                            onTap: () => _openClassDetail(classroom),
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TeacherClassroomEntrance extends StatefulWidget {
  const _TeacherClassroomEntrance({
    required this.order,
    required this.child,
    this.onFinished,
  });

  final int order;
  final Widget child;
  final VoidCallback? onFinished;

  @override
  State<_TeacherClassroomEntrance> createState() =>
      _TeacherClassroomEntranceState();
}

class _TeacherClassroomEntranceState extends State<_TeacherClassroomEntrance> {
  bool _isVisible = false;
  bool _hasNotifiedFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(
        Duration(milliseconds: 55 * widget.order.clamp(0, 8)),
      );
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  void _notifyFinished() {
    if (_hasNotifiedFinished) {
      return;
    }
    _hasNotifiedFinished = true;
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _notifyFinished());
      return widget.child;
    }

    return AnimatedOpacity(
      opacity: _isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : const Offset(0, 0.055),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _isVisible ? 1 : 0.96,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          onEnd: _isVisible ? _notifyFinished : null,
          child: widget.child,
        ),
      ),
    );
  }
}

class _TeacherClassroomLoadingContent extends StatelessWidget {
  const _TeacherClassroomLoadingContent({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _TeacherSkeletonBlock(
            width: 90 * scale,
            height: 36 * scale,
            radius: 12 * scale,
            color: _teacherCoral.withValues(alpha: 0.18),
          ),
        ),
        SizedBox(height: 16 * scale),
        _TeacherSkeletonCard(
          scale: scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: SizedBox(
            height: 48 * scale,
            child: Row(
              children: [
                _TeacherSkeletonBlock(
                  width: 24 * scale,
                  height: 24 * scale,
                  radius: 12 * scale,
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _TeacherSkeletonBlock(
                    width: double.infinity,
                    height: 14 * scale,
                    radius: 7 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                _TeacherSkeletonBlock(
                  width: 24 * scale,
                  height: 24 * scale,
                  radius: 12 * scale,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24 * scale),
        for (var index = 0; index < 3; index++) ...[
          _TeacherClassroomSkeletonCard(scale: scale),
          if (index != 2) SizedBox(height: 16 * scale),
        ],
      ],
    );
  }
}

class _TeacherClassroomSkeletonCard extends StatelessWidget {
  const _TeacherClassroomSkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonCard(
      scale: scale,
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 18 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TeacherSkeletonBlock(
                width: 76 * scale,
                height: 76 * scale,
                radius: 16 * scale,
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TeacherSkeletonBlock(
                        width: 128 * scale,
                        height: 21 * scale,
                        radius: 10.5 * scale,
                      ),
                      SizedBox(height: 16 * scale),
                      _TeacherSkeletonBlock(
                        width: 142 * scale,
                        height: 18 * scale,
                        radius: 9 * scale,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          _TeacherSkeletonBlock(
            width: 132 * scale,
            height: 18 * scale,
            radius: 9 * scale,
          ),
        ],
      ),
    );
  }
}

class _ClassroomListCard extends StatelessWidget {
  const _ClassroomListCard({
    required this.scale,
    required this.classroom,
    required this.onTap,
  });

  final double scale;
  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title =
        classroom.name ?? context.getText(AppKeys.teacherClassFallback);
    final code = classroom.classroomCode ?? classroom.id?.toString() ?? '--';
    final memberCount = classroom.displayStudentCount;
    final classNumber = _teacherClassNumber(classroom);
    final numberPalette = _teacherClassNumberPalette(classroom);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * scale),
          border: Border.all(color: const Color(0xFFE9EEF2)),
          boxShadow: [
            BoxShadow(
              color: _teacherBlue.withValues(alpha: 0.035),
              blurRadius: 18 * scale,
              offset: Offset(0, 5 * scale),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 18 * scale,
          vertical: 18 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TeacherClassNumberBadge(
                  scale: scale,
                  number: classNumber,
                  palette: numberPalette,
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: _teacherBlue,
                            fontSize: 21 * scale,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        Text(
                          'ID: $code',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: const Color(0xFF484B56),
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: const Color(0xFF4B4E5A),
                  size: 17 * scale,
                ),
                SizedBox(width: 7 * scale),
                Flexible(
                  child: Text(
                    context.formatText(
                      AppKeys.teacherStudentCount,
                      {'count': memberCount},
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: const Color(0xFF4B4E5A),
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherClassNumberBadge extends StatelessWidget {
  const _TeacherClassNumberBadge({
    required this.scale,
    required this.number,
    required this.palette,
  });

  final double scale;
  final String number;
  final _TeacherClassNumberPalette palette;

  TextStyle get _numberStyle => TextStyle(
        fontSize: 50 * scale,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      );

  @override
  Widget build(BuildContext context) {
    final radius = 16 * scale;
    return Container(
      width: 76 * scale,
      height: 76 * scale,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.45, -0.5),
                  radius: 1.05,
                  colors: [
                    Colors.white.withValues(alpha: 0.85),
                    palette.background,
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(3.5 * scale, 5.5 * scale),
            child: Text(number,
                style: _numberStyle.copyWith(color: palette.shadow)),
          ),
          Transform.translate(
            offset: Offset(0, 3 * scale),
            child: Text(
              number,
              style: _numberStyle.copyWith(
                color: palette.depth,
                shadows: [
                  Shadow(
                    color: palette.shadow,
                    offset: Offset(2 * scale, 2.6 * scale),
                    blurRadius: 2 * scale,
                  ),
                ],
              ),
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.top, palette.bottom],
              stops: const [0.12, 0.88],
            ).createShader(bounds),
            child:
                Text(number, style: _numberStyle.copyWith(color: Colors.white)),
          ),
          Positioned(
            top: 17 * scale,
            left: 26 * scale,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 13 * scale,
                height: 5 * scale,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherClassNumberPalette {
  const _TeacherClassNumberPalette({
    required this.top,
    required this.bottom,
    required this.depth,
    required this.shadow,
    required this.background,
    required this.border,
  });

  final Color top;
  final Color bottom;
  final Color depth;
  final Color shadow;
  final Color background;
  final Color border;
}

const _teacherClassNumberPalettes = <_TeacherClassNumberPalette>[
  _TeacherClassNumberPalette(
    top: Color(0xFF76DCCB),
    bottom: Color(0xFF3DB9A5),
    depth: Color(0xFF168A7C),
    shadow: Color(0x55384350),
    background: Color(0xFFEAF9F7),
    border: Color(0xFFCDEDEA),
  ),
  _TeacherClassNumberPalette(
    top: Color(0xFF20C8ED),
    bottom: Color(0xFF0794D3),
    depth: Color(0xFF075FB3),
    shadow: Color(0x55384350),
    background: Color(0xFFEAF7FF),
    border: Color(0xFFD2ECFA),
  ),
  _TeacherClassNumberPalette(
    top: Color(0xFFFFDA17),
    bottom: Color(0xFFFFA800),
    depth: Color(0xFFF06B17),
    shadow: Color(0x55384350),
    background: Color(0xFFFFF7DE),
    border: Color(0xFFFFE8AC),
  ),
  _TeacherClassNumberPalette(
    top: Color(0xFFA9DD35),
    bottom: Color(0xFF71BD26),
    depth: Color(0xFF2A8B22),
    shadow: Color(0x55384350),
    background: Color(0xFFF1FAE6),
    border: Color(0xFFDDEFC1),
  ),
  _TeacherClassNumberPalette(
    top: Color(0xFFFF514B),
    bottom: Color(0xFFF01422),
    depth: Color(0xFFB8071C),
    shadow: Color(0x55384350),
    background: Color(0xFFFFEEEE),
    border: Color(0xFFFFD5D5),
  ),
];

String _teacherClassNumber(ClassroomModel classroom) {
  final source = [
    classroom.name,
    classroom.classroomCode,
    classroom.id?.toString(),
  ].whereType<String>().join(' ');
  final match = RegExp(r'\d+').firstMatch(source);
  return match?.group(0) ?? '1';
}

_TeacherClassNumberPalette _teacherClassNumberPalette(
    ClassroomModel classroom) {
  final seed =
      classroom.stableId ?? classroom.id ?? classroom.name?.hashCode ?? 0;
  return _teacherClassNumberPalettes[
      seed.abs() % _teacherClassNumberPalettes.length];
}
