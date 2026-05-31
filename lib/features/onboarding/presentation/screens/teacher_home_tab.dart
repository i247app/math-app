part of 'teacher_classroom_screens.dart';

class TeacherHomeTab extends StatefulWidget {
  const TeacherHomeTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.scale,
    required this.onCompleteProfile,
    ClassroomService? classroomService,
  }) : _classroomService = classroomService;

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final double scale;
  final Future<void> Function() onCompleteProfile;
  final ClassroomService? _classroomService;

  @override
  State<TeacherHomeTab> createState() => _TeacherHomeTabState();
}

class _TeacherHomeTabState extends State<TeacherHomeTab> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();

  bool _isLoading = false;
  String? _error;
  int? _loadedProfileId;
  List<ClassroomModel> _classrooms = const <ClassroomModel>[];

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
    }
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
      setState(() => _classrooms = classrooms);
    } on ClassroomException catch (error) {
      if (!mounted || _loadedProfileId != profileId) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted && _loadedProfileId == profileId) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCreateClass() async {
    HapticFeedback.lightImpact();
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TeacherCreateClassScreen(
          user: widget.user,
          activeProfile: widget.activeProfile,
        ),
      ),
    );
    if (created == true) {
      await _loadClassrooms();
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

  Future<void> _openClassDetail(ClassroomModel classroom) async {
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
          initialClassroom: classroom,
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
    final scale = widget.scale;
    final isProfileComplete = _isTeacherProfileComplete(widget.activeProfile);

    return RefreshIndicator(
      color: _teacherTeal,
      onRefresh: _loadClassrooms,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          18 * scale,
          0,
          18 * scale,
          widget.bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TeacherTopBar(
              profile: widget.activeProfile,
              topPadding: MediaQuery.paddingOf(context).top,
              scale: scale,
            ),
            SizedBox(height: 22 * scale),
            _TeacherHeroCard(scale: scale),
            SizedBox(height: 28 * scale),
            _TeacherClassSectionHeader(
              scale: scale,
              hasClasses: _classrooms.isNotEmpty,
              onAdd: _handleClassCreateAction,
            ),
            SizedBox(height: (_classrooms.isNotEmpty ? 5 : 12) * scale),
            if (_isLoading && _classrooms.isEmpty)
              _TeacherLoadingPanel(scale: scale)
            else if (_error != null && _classrooms.isEmpty)
              _TeacherErrorPanel(
                scale: scale,
                message: _error!,
                onRetry: _loadClassrooms,
              )
            else if (_classrooms.isEmpty)
              _TeacherNoClassPanel(
                scale: scale,
                isProfileComplete: isProfileComplete,
                onCreate: _handleClassCreateAction,
              )
            else
              _TeacherClassGrid(
                scale: scale,
                classrooms: _classrooms,
                onOpen: _openClassDetail,
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
        20 * scale,
        topPadding + 16 * scale,
        20 * scale,
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
                    fontSize: 12 * scale,
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
                    fontSize: 18 * scale,
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
                  fontSize: 18 * scale,
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
                  fontSize: 14 * scale,
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
  });

  final double scale;
  final bool hasClasses;
  final VoidCallback onAdd;

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
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
            Text(
              context.getText(AppKeys.viewAllUpper),
              style: GoogleFonts.andika(
                color: _teacherInk,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                height: 1.25,
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

class _TeacherClassGrid extends StatelessWidget {
  const _TeacherClassGrid({
    required this.scale,
    required this.classrooms,
    required this.onOpen,
  });

  final double scale;
  final List<ClassroomModel> classrooms;
  final ValueChanged<ClassroomModel> onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      clipBehavior: Clip.none,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classrooms.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16 * scale,
        mainAxisSpacing: 16 * scale,
        mainAxisExtent: 168 * scale,
      ),
      itemBuilder: (context, index) {
        final classroom = classrooms[index];
        return _TeacherClassCard(
          scale: scale,
          classroom: classroom,
          onTap: () => onOpen(classroom),
        );
      },
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
            padding: EdgeInsets.all(16 * scale),
            child: Column(
              children: [
                _ClassThumb(classroom: classroom, scale: scale),
                SizedBox(height: 10 * scale),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.andika(
                    color: Colors.black,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const Spacer(),
                Divider(color: const Color(0x1AC4C6D2), height: 8 * scale),
                Text(
                  context.formatText(
                    AppKeys.teacherStudentCount,
                    {'count': classroom.displayMemberCount},
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherBlue.withValues(alpha: 0.60),
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 5 * scale),
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
                      fontSize: 11 * scale,
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
    return SizedBox(
      height: 220 * scale,
      child: const Center(
        child: CircularProgressIndicator(color: _teacherTeal),
      ),
    );
  }
}
