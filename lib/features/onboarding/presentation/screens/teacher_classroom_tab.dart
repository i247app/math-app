part of 'teacher_classroom_screens.dart';

class TeacherClassroomTab extends StatefulWidget {
  const TeacherClassroomTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.scale,
    ClassroomService? classroomService,
  }) : _classroomService = classroomService;

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final double scale;
  final ClassroomService? _classroomService;

  @override
  State<TeacherClassroomTab> createState() => _TeacherClassroomTabState();
}

class _TeacherClassroomTabState extends State<TeacherClassroomTab> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();

  bool _isLoading = false;
  String? _error;
  int? _loadedProfileId;
  List<ClassroomModel> _classrooms = const <ClassroomModel>[];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  @override
  void didUpdateWidget(covariant TeacherClassroomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId != _loadedProfileId) {
      _loadClassrooms();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClassrooms() async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId == null) {
      setState(() {
        _loadedProfileId = profileId;
        _classrooms = const <ClassroomModel>[];
        _error = context.readText(AppKeys.teacherMissingProfileId);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _loadedProfileId = profileId;
    });

    try {
      final classrooms =
          await _classroomService.listClassrooms(profileId: profileId);
      if (!mounted || _loadedProfileId != profileId) {
        return;
      }
      setState(() {
        _classrooms = classrooms;
        _isLoading = false;
      });
    } on ClassroomException catch (error) {
      if (!mounted || _loadedProfileId != profileId) {
        return;
      }
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    } finally {
      if (mounted && _loadedProfileId == profileId) {
        setState(() => _isLoading = false);
      }
    }
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
      await _loadClassrooms();
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
    final scale = widget.scale;

    // Filter logic can be added later, for now just show all
    final displayedClassrooms = _classrooms;

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
                    fontSize: 24,
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

                // Add button
                Align(
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
                SizedBox(height: 16 * scale),

                // Search bar
                Container(
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
                      Icon(Icons.search, color: _teacherBlue, size: 24 * scale),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          style: GoogleFonts.andika(
                            color: _teacherInk,
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: context
                                .getText(AppKeys.teacherSearchClassroomHint),
                            hintStyle: GoogleFonts.andika(
                              color: _teacherMuted.withValues(alpha: 0.6),
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      Icon(Icons.tune, color: _teacherBlue, size: 24 * scale),
                      SizedBox(width: 16 * scale),
                    ],
                  ),
                ),
                SizedBox(height: 24 * scale),

                if (_isLoading && _classrooms.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child:
                          const CircularProgressIndicator(color: _teacherTeal),
                    ),
                  )
                else if (_error != null && _classrooms.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: 14 * scale,
                        ),
                      ),
                    ),
                  )
                else if (_classrooms.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Text(
                        context.getText(AppKeys.teacherEmptyClassroomList),
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: 16 * scale,
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
                      return _ClassroomListCard(
                        scale: scale,
                        classroom: classroom,
                        onTap: () => _openClassDetail(classroom),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
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

    // For the image, we try to use avatarKey/Url or just a placeholder box
    // To match the image, we use a dark container with _HeroMathGlyph if nothing is provided

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: const Color(0xFFF2F4F7)),
          boxShadow: [
            BoxShadow(
              color: _teacherBlue.withValues(alpha: 0.04),
              blurRadius: 16 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        padding: EdgeInsets.all(16 * scale),
        child: Row(
          children: [
            Container(
              width: 80 * scale,
              height: 80 * scale,
              decoration: BoxDecoration(
                color: _teacherBlue,
                borderRadius: BorderRadius.circular(16 * scale),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF293B4E), Color(0xFF0F1B2A)],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16 * scale),
                child: ProfileAvatarImage(
                  size: 80 * scale,
                  avatarUrl: classroom.avatarUrl ?? classroom.imageUrl,
                  fallbackAsset: 'assets/images/numi-mascot.png',
                ),
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: _teacherBlue,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    'ID: $code',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: _teacherMuted,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: _teacherMuted,
                        size: 16 * scale,
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        context.formatText(
                          AppKeys.teacherStudentCount,
                          {'count': memberCount},
                        ),
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
