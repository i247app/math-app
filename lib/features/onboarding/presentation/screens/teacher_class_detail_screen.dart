part of 'teacher_classroom_screens.dart';

class TeacherClassDetailScreen extends StatefulWidget {
  const TeacherClassDetailScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this.initialClassroom,
    ClassroomService? classroomService,
  }) : _classroomService = classroomService;

  final String classroomId;
  final String profileId;
  final ClassroomModel? initialClassroom;
  final ClassroomService? _classroomService;

  @override
  State<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();

  bool _isLoading = false;
  String? _error;
  ClassroomModel? _classroom;

  @override
  void initState() {
    super.initState();
    _classroom = widget.initialClassroom;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final classroom = await _classroomService.getClassroomDetail(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
      );
      if (!mounted) {
        return;
      }
      setState(() => _classroom = classroom ?? _classroom);
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teacherPaleMint,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = math.min(constraints.maxWidth / 390, 1.12);
            final classroom = _classroom;
            final students = classroom?.students ?? const <ClassroomStudent>[];
            final count = classroom?.displayMemberCount ?? students.length;

            return Column(
              children: [
                _TeacherScreenAppBar(
                  title: context.getText(AppKeys.teacherClassDetailTitle),
                  scale: scale,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: _teacherTeal,
                    onRefresh: _loadDetail,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        16 * scale,
                        18 * scale,
                        16 * scale,
                        MediaQuery.paddingOf(context).bottom + 28 * scale,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_error != null && classroom == null)
                            _TeacherErrorPanel(
                              scale: scale,
                              message: _error!,
                              onRetry: _loadDetail,
                            )
                          else
                            _ClassDetailInfoCard(
                              scale: scale,
                              classroom: classroom,
                              isLoading: _isLoading && classroom == null,
                            ),
                          SizedBox(height: 23 * scale),
                          _SmallCoralAddButton(
                            scale: scale,
                            onTap: () {},
                            width: 79 * scale,
                          ),
                          SizedBox(height: 9 * scale),
                          if (_error == null || classroom != null)
                            _StudentListCard(
                              scale: scale,
                              students: students,
                              count: count,
                              isLoading: _isLoading && classroom == null,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ClassDetailInfoCard extends StatelessWidget {
  const _ClassDetailInfoCard({
    required this.scale,
    required this.classroom,
    required this.isLoading,
  });

  final double scale;
  final ClassroomModel? classroom;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final title = _nonEmpty(classroom?.name) ??
        context.getText(AppKeys.teacherClassFallback);
    final grade =
        _detailLabel(context.getText(AppKeys.grade), classroom?.gradeId);
    final program = _nonEmpty(classroom?.programId) ??
        context.getText(AppKeys.teacherProgramFallback);
    final description = _nonEmpty(classroom?.description) ??
        context.getText(AppKeys.teacherDescriptionFallback);
    final code = _classCode(classroom);
    final joinLink = 'numinumi.vn/join/$code';

    return Container(
      width: double.infinity,
      height: 273 * scale,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        15 * scale,
        16 * scale,
        1 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0x80CCCCCC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 10 * scale,
            offset: Offset(3 * scale, 3 * scale),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: _teacherTeal))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 67 * scale,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 71 * scale,
                        height: 64 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/images/teacher_class_graduation.svg',
                          width: 40 * scale,
                          height: 40 * scale,
                        ),
                      ),
                      SizedBox(width: 15 * scale),
                      Expanded(
                        child: SizedBox(
                          height: 64 * scale,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.andika(
                                    color: _teacherInk,
                                    fontSize: 20 * scale,
                                    fontWeight: FontWeight.w700,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _copyClassroomInfo(
                                  context,
                                  joinLink,
                                  context
                                      .getText(AppKeys.teacherCopiedClassLink),
                                ),
                                borderRadius: BorderRadius.circular(8 * scale),
                                child: Padding(
                                  padding: EdgeInsets.all(4 * scale),
                                  child: Image.asset(
                                    'assets/images/teacher_class_share.png',
                                    width: 23 * scale,
                                    height: 23 * scale,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * scale),
                SizedBox(
                  height: 74 * scale,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ClassDetailMetaRow(
                        scale: scale,
                        iconAsset: 'assets/images/teacher_class_grade.png',
                        text: grade,
                      ),
                      SizedBox(height: 5 * scale),
                      _ClassDetailMetaRow(
                        scale: scale,
                        iconAsset: 'assets/images/teacher_class_program.png',
                        text: program,
                      ),
                      SizedBox(height: 5 * scale),
                      _ClassDetailMetaRow(
                        scale: scale,
                        iconAsset:
                            'assets/images/teacher_class_description.png',
                        text: description,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14 * scale),
                SizedBox(
                  height: 27 * scale,
                  child: Row(
                    children: [
                      _ClassCodeChip(
                        scale: scale,
                        code: code,
                        onCopy: () => _copyClassroomInfo(
                          context,
                          code,
                          context.getText(AppKeys.teacherCopiedClassCode),
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/images/teacher_class_qr.png',
                        width: 18 * scale,
                        height: 18 * scale,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 11 * scale),
                Container(
                  height: 38 * scale,
                  padding: EdgeInsets.symmetric(horizontal: 21 * scale),
                  decoration: BoxDecoration(
                    color: _teacherMint,
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: const Color(0xFFEFF6FF)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          joinLink,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: const Color(0xFF1E3A5F),
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w400,
                            height: 1.7,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      InkWell(
                        onTap: () => _copyClassroomInfo(
                          context,
                          joinLink,
                          context.getText(AppKeys.teacherCopiedClassLink),
                        ),
                        borderRadius: BorderRadius.circular(8 * scale),
                        child: Padding(
                          padding: EdgeInsets.all(2 * scale),
                          child: SvgPicture.asset(
                            'assets/images/teacher_class_copy.svg',
                            width: 20 * scale,
                            height: 20 * scale,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ClassDetailMetaRow extends StatelessWidget {
  const _ClassDetailMetaRow({
    required this.scale,
    required this.iconAsset,
    required this.text,
  });

  final double scale;
  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20 * scale,
      child: Row(
        children: [
          Image.asset(
            iconAsset,
            width: 18 * scale,
            height: 18 * scale,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: const Color(0xFF001741),
                fontSize: 14 * scale,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCodeChip extends StatelessWidget {
  const _ClassCodeChip({
    required this.scale,
    required this.code,
    required this.onCopy,
  });

  final double scale;
  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27 * scale,
      constraints: BoxConstraints(
        minWidth: 114 * scale,
        maxWidth: 190 * scale,
      ),
      padding: EdgeInsets.symmetric(horizontal: 17 * scale),
      decoration: BoxDecoration(
        color: _teacherMint,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                code,
                maxLines: 1,
                style: GoogleFonts.andika(
                  color: const Color(0xFF1E3A5F),
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.8,
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8 * scale),
            child: Padding(
              padding: EdgeInsets.all(2 * scale),
              child: SvgPicture.asset(
                'assets/images/teacher_class_link_copy.svg',
                width: 20 * scale,
                height: 20 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentListCard extends StatelessWidget {
  const _StudentListCard({
    required this.scale,
    required this.students,
    required this.count,
    required this.isLoading,
  });

  final double scale;
  final List<ClassroomStudent> students;
  final int count;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 22 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0x80CCCCCC)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.formatText(
                    AppKeys.teacherJoinedStudents,
                    {'count': count},
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherInk,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
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
                  height: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(color: _teacherTeal),
            )
          else if (students.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18 * scale),
              child: Text(
                context.getText(AppKeys.teacherNoJoinedStudents),
                style: GoogleFonts.andika(
                  color: _teacherMuted,
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            for (var index = 0; index < students.length; index++)
              _StudentRow(
                student: students[index],
                index: index,
                scale: scale,
              ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.index,
    required this.scale,
  });

  final ClassroomStudent student;
  final int index;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = _studentAvatarColors(index);
    final name = student.name?.trim().isNotEmpty == true
        ? student.name!.trim()
        : context.getText(AppKeys.teacherStudentFallback);
    return Container(
      padding: EdgeInsets.only(top: index == 0 ? 0 : 16 * scale),
      margin: EdgeInsets.only(top: index == 0 ? 0 : 16 * scale),
      decoration: BoxDecoration(
        border: index == 0
            ? null
            : const Border(top: BorderSide(color: Color(0xFFF9FAFB))),
      ),
      child: Row(
        children: [
          _InitialsAvatar(
            initials: _initials(name),
            background: colors.$1,
            foreground: colors.$2,
            scale: scale,
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: const Color(0xFF1E3A5F),
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                Text(
                  context.getText(AppKeys.teacherJustJoined),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherMuted,
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8 * scale,
            height: 8 * scale,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.initials,
    required this.background,
    required this.foreground,
    required this.scale,
  });

  final String initials;
  final Color background;
  final Color foreground;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40 * scale,
      height: 40 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: foreground.withValues(alpha: 0.15)),
      ),
      child: Text(
        initials,
        style: GoogleFonts.andika(
          color: foreground,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String _detailLabel(String prefix, String? value) {
  final trimmed = _nonEmpty(value);
  if (trimmed == null) {
    return prefix;
  }
  final lower = trimmed.toLowerCase();
  if (lower.startsWith(prefix.toLowerCase())) {
    return trimmed;
  }
  return '$prefix $trimmed';
}

String _classCode(ClassroomModel? classroom) {
  final inviteCode = _nonEmpty(classroom?.inviteCode);
  if (inviteCode != null) {
    return inviteCode;
  }
  final stableId = _nonEmpty(classroom?.stableId);
  if (stableId == null) {
    return 'NM-9988';
  }
  final cleaned = stableId.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
  if (cleaned.isEmpty) {
    return 'NM-9988';
  }
  final suffix = cleaned.length > 4
      ? cleaned.substring(cleaned.length - 4)
      : cleaned.padLeft(4, '0');
  return 'NM-$suffix';
}

void _copyClassroomInfo(BuildContext context, String value, String message) {
  Clipboard.setData(ClipboardData(text: value));
  HapticFeedback.selectionClick();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.andika(),
        ),
        duration: const Duration(milliseconds: 1400),
      ),
    );
}
