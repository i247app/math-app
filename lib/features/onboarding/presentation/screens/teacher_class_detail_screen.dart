part of 'teacher_classroom_screens.dart';

class TeacherClassDetailScreen extends StatefulWidget {
  const TeacherClassDetailScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this.initialClassroom,
    ClassroomService? classroomService,
  }) : _classroomService = classroomService;

  final int classroomId;
  final int profileId;
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
      setState(() {
        _classroom = classroom ?? _classroom;
      });
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
            final count = classroom?.displayStudentCount ?? students.length;
            final requestCount = classroom?.displayPendingRequestCount ?? 0;

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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          if (_error == null || classroom != null)
                            _ClassDetailLowerContent(
                              scale: scale,
                              memberCount: count,
                              requestCount: requestCount,
                              onOpenMembers: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => TeacherClassMembersScreen(
                                      classroomId: widget.classroomId,
                                      profileId: widget.profileId,
                                      classroomService: _classroomService,
                                    ),
                                  ),
                                );
                                if (mounted) {
                                  _loadDetail();
                                }
                              },
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
        _detailIdLabel(context.getText(AppKeys.grade), classroom?.gradeId);
    final program = _displayBackendId(classroom?.programId) ??
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

class _ClassDetailLowerContent extends StatelessWidget {
  const _ClassDetailLowerContent({
    required this.scale,
    required this.memberCount,
    required this.requestCount,
    required this.onOpenMembers,
  });

  final double scale;
  final int memberCount;
  final int requestCount;
  final VoidCallback onOpenMembers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MemberManagementCard(
            scale: scale,
            memberCount: memberCount,
            requestCount: requestCount,
            onTap: onOpenMembers,
          ),
          SizedBox(height: 27 * scale),
          Text(
            context.getText(AppKeys.teacherClassFunctions),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: const Color(0xFF1E3A5F),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              height: 1.55,
            ),
          ),
          SizedBox(height: 7 * scale),
          _ClassFunctionGrid(scale: scale),
        ],
      ),
    );
  }
}

class _MemberManagementCard extends StatelessWidget {
  const _MemberManagementCard({
    required this.scale,
    required this.memberCount,
    required this.requestCount,
    required this.onTap,
  });

  final double scale;
  final int memberCount;
  final int requestCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16 * scale);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 77 * scale),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: 21 * scale,
              vertical: 14 * scale,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48 * scale,
                  height: 48 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Image.asset(
                    'assets/images/teacher_class_members.png',
                    width: 28 * scale,
                    height: 28 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.getText(AppKeys.teacherMemberManagement),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: const Color(0xFF1E3A5F),
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w700,
                          height: 1.22,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        _teacherMemberSummaryText(
                          context,
                          members: memberCount,
                          requests: requestCount,
                        ),
                        maxLines: requestCount > 0 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/teacher_class_chevron.svg',
                  width: 20 * scale,
                  height: 20 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassFunctionGrid extends StatelessWidget {
  const _ClassFunctionGrid({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10 * scale,
      mainAxisSpacing: 10 * scale,
      childAspectRatio: 148 / 90,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _ClassFunctionTile(
          scale: scale,
          iconAsset: 'assets/images/teacher_class_assignment.png',
          label: context.getText(AppKeys.teacherAssignments),
        ),
        _ClassFunctionTile(scale: scale),
        _ClassFunctionTile(scale: scale),
        _ClassFunctionTile(scale: scale),
      ],
    );
  }
}

class _ClassFunctionTile extends StatelessWidget {
  const _ClassFunctionTile({
    required this.scale,
    this.iconAsset,
    this.label,
  });

  final double scale;
  final String? iconAsset;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0xFFDDE4E6),
          width: 2 * scale,
        ),
      ),
      child: iconAsset == null
          ? const SizedBox.shrink()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconAsset!,
                  width: 44 * scale,
                  height: 44 * scale,
                ),
                SizedBox(height: 1 * scale),
                Text(
                  label ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.andika(
                    color: _teacherInk,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                  ),
                ),
              ],
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

String _detailIdLabel(String prefix, int? value) {
  final displayValue = _displayBackendId(value);
  if (displayValue == null) {
    return prefix;
  }
  return '$prefix $displayValue';
}

String? _displayBackendId(int? value) => value == null ? null : '$value';

String _classCode(ClassroomModel? classroom) {
  final classroomCode = _nonEmpty(classroom?.classroomCode);
  if (classroomCode != null) {
    return classroomCode;
  }
  final stableId = classroom?.stableId;
  if (stableId == null) {
    return 'NM-9988';
  }
  final cleaned = _displayClassStableId(stableId);
  if (cleaned.isEmpty) {
    return 'NM-9988';
  }
  final suffix = cleaned.length > 4
      ? cleaned.substring(cleaned.length - 4)
      : cleaned.padLeft(4, '0');
  return 'NM-$suffix';
}

String _displayClassStableId(int value) => '$value';

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
