part of 'teacher_classroom_screens.dart';

class TeacherClassMembersScreen extends StatelessWidget {
  const TeacherClassMembersScreen({
    super.key,
    ProfileService? profileService,
  }) : _profileService = profileService;

  final ProfileService? _profileService;

  static const _fakeJoinRequests = <_FakeClassMember>[
    _FakeClassMember(
      name: 'Nguyễn Thị D',
      initials: 'ND',
      avatarBackground: Color(0xFFE0F2F1),
      avatarBorder: Color(0xFFB2DFDB),
      initialsColor: Color(0xFF00796B),
    ),
    _FakeClassMember(
      name: 'Mai Văn T',
      initials: 'MT',
      avatarBackground: Color(0xFFFCE4EC),
      avatarBorder: Color(0xFFFCE7F3),
      initialsColor: Color(0xFFF06292),
    ),
  ];

  static const _fakeMembers = <_FakeClassMember>[
    _FakeClassMember(
      name: 'Nguyễn Văn A',
      statusKey: AppKeys.teacherJustJoined,
      avatarAsset: 'assets/images/teacher_member_avatar_1.png',
    ),
    _FakeClassMember(
      name: 'Trần Thị B',
      statusKey: AppKeys.teacherTwoMinutesAgo,
      avatarAsset: 'assets/images/teacher_member_avatar_2.png',
    ),
    _FakeClassMember(
      name: 'Lê Văn C',
      statusKey: AppKeys.teacherFiveMinutesAgo,
      initials: 'L',
      avatarBackground: Color(0x1A7895D9),
      initialsColor: Color(0xFF7895D9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teacherPaleMint,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = math.min(constraints.maxWidth / 390, 1.12);
            return Column(
              children: [
                _TeacherScreenAppBar(
                  title: context.getText(AppKeys.teacherMembersTitle),
                  scale: scale,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      15 * scale,
                      31 * scale,
                      15 * scale,
                      MediaQuery.paddingOf(context).bottom + 32 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: _TeacherMemberAddButton(
                            scale: scale,
                            onTap: () => _openStudentSearchSheet(context),
                          ),
                        ),
                        SizedBox(height: 15 * scale),
                        _TeacherMemberSectionTitle(
                          scale: scale,
                          title: context.formatText(
                            AppKeys.teacherJoinRequests,
                            {'count': _fakeJoinRequests.length},
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        _JoinRequestCard(
                          scale: scale,
                          requests: _fakeJoinRequests,
                        ),
                        SizedBox(height: 28 * scale),
                        _TeacherMemberSectionTitle(
                          scale: scale,
                          title: context.formatText(
                            AppKeys.teacherJoinedStudentsTitle,
                            {'count': _fakeMembers.length},
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        for (var index = 0;
                            index < _fakeMembers.length;
                            index++) ...[
                          _JoinedMemberCard(
                            scale: scale,
                            member: _fakeMembers[index],
                          ),
                          if (index != _fakeMembers.length - 1)
                            SizedBox(height: 12 * scale),
                        ],
                      ],
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

  Future<void> _openStudentSearchSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<List<StudentProfile>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _StudentInviteSearchSheet(
        profileService: _profileService ?? ProfileApi(),
      ),
    );
    if (selected == null || selected.isEmpty || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            context.formatText(
              AppKeys.teacherInviteRequestQueued,
              {'count': selected.length},
            ),
            style: GoogleFonts.andika(),
          ),
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }
}

class _TeacherMemberAddButton extends StatelessWidget {
  const _TeacherMemberAddButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12 * scale);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Material(
        color: _teacherCoral,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 82 * scale,
            height: 31 * scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12 * scale),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.6, 0.6, 1],
                        colors: [
                          Colors.white.withValues(alpha: 0.20),
                          Colors.white.withValues(alpha: 0.0),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/teacher_class_add.svg',
                  width: 12 * scale,
                  height: 12 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherMemberSectionTitle extends StatelessWidget {
  const _TeacherMemberSectionTitle({
    required this.scale,
    required this.title,
  });

  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.andika(
        color: const Color(0xFF1E3A5F),
        fontSize: 18 * scale,
        fontWeight: FontWeight.w700,
        height: 1.55,
      ),
    );
  }
}

class _StudentInviteSearchSheet extends StatefulWidget {
  const _StudentInviteSearchSheet({required this.profileService});

  final ProfileService profileService;

  @override
  State<_StudentInviteSearchSheet> createState() =>
      _StudentInviteSearchSheetState();
}

class _StudentInviteSearchSheetState extends State<_StudentInviteSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedProfileIds = <int>{};
  final Map<int, StudentProfile> _selectedProfilesById =
      <int, StudentProfile>{};

  Timer? _debounce;
  List<StudentProfile> _results = const <StudentProfile>[];
  bool _isSearching = false;
  String? _error;
  int _requestSerial = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      _searchProfiles(value);
    });
  }

  Future<void> _searchProfiles(String value) async {
    final keyword = value.trim();
    _requestSerial += 1;
    final requestId = _requestSerial;
    if (keyword.isEmpty) {
      setState(() {
        _results = const <StudentProfile>[];
        _isSearching = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });
    try {
      final profiles = await widget.profileService.searchProfiles(
        search: keyword,
      );
      if (!mounted || requestId != _requestSerial) {
        return;
      }
      setState(() {
        _results = profiles.where(_isStudentProfile).toList();
      });
    } on ProfileException catch (error) {
      if (!mounted || requestId != _requestSerial) {
        return;
      }
      setState(() {
        _error = error.message;
        _results = const <StudentProfile>[];
      });
    } finally {
      if (mounted && requestId == _requestSerial) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _toggleProfile(StudentProfile profile) {
    final id = ActiveProfileSession.profileStableId(profile);
    if (id == null) {
      return;
    }
    setState(() {
      if (!_selectedProfileIds.add(id)) {
        _selectedProfileIds.remove(id);
        _selectedProfilesById.remove(id);
      } else {
        _selectedProfilesById[id] = profile;
      }
    });
  }

  List<StudentProfile> get _selectedProfiles =>
      _selectedProfilesById.values.toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final selectedCount = _selectedProfileIds.length;
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomInset),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE4E6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.getText(AppKeys.teacherSearchStudentTitle),
                style: GoogleFonts.andika(
                  color: const Color(0xFF1E3A5F),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: _searchProfiles,
                decoration: InputDecoration(
                  hintText: context.getText(AppKeys.teacherSearchStudentHint),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: _teacherPaleMint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDDE4E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDDE4E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _teacherTeal),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.formatText(
                  AppKeys.teacherSelectedStudents,
                  {'count': selectedCount},
                ),
                style: GoogleFonts.andika(
                  color: _teacherMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _StudentSearchResultList(
                  scrollController: scrollController,
                  profiles: _results,
                  selectedProfileIds: _selectedProfileIds,
                  isSearching: _isSearching,
                  error: _error,
                  query: _searchController.text.trim(),
                  onToggle: _toggleProfile,
                ),
              ),
              const SizedBox(height: 12),
              _SendInviteButton(
                enabled: selectedCount > 0,
                onTap: selectedCount == 0
                    ? null
                    : () => Navigator.of(context).pop(_selectedProfiles),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StudentSearchResultList extends StatelessWidget {
  const _StudentSearchResultList({
    required this.scrollController,
    required this.profiles,
    required this.selectedProfileIds,
    required this.isSearching,
    required this.error,
    required this.query,
    required this.onToggle,
  });

  final ScrollController scrollController;
  final List<StudentProfile> profiles;
  final Set<int> selectedProfileIds;
  final bool isSearching;
  final String? error;
  final String query;
  final ValueChanged<StudentProfile> onToggle;

  @override
  Widget build(BuildContext context) {
    if (isSearching && profiles.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: _teacherTeal));
    }
    if (error != null) {
      return Center(
        child: Text(
          context.getText(AppKeys.teacherSearchStudentFailed),
          textAlign: TextAlign.center,
          style: GoogleFonts.andika(
            color: _teacherMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (query.isNotEmpty && profiles.isEmpty) {
      return Center(
        child: Text(
          context.getText(AppKeys.teacherNoStudentResults),
          textAlign: TextAlign.center,
          style: GoogleFonts.andika(
            color: _teacherMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: profiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final profile = profiles[index];
        final id = ActiveProfileSession.profileStableId(profile);
        final selected = id != null && selectedProfileIds.contains(id);
        return _StudentSearchResultTile(
          profile: profile,
          selected: selected,
          onTap: () => onToggle(profile),
        );
      },
    );
  }
}

class _StudentSearchResultTile extends StatelessWidget {
  const _StudentSearchResultTile({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final StudentProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = profile.name?.trim().isNotEmpty == true
        ? profile.name!.trim()
        : context.getText(AppKeys.teacherStudentFallback);
    final subtitle = _studentSearchSubtitle(context, profile);
    return Material(
      color: selected ? const Color(0xFFE8F7F7) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _teacherTeal : const Color(0xFFE5ECEF),
            ),
          ),
          child: Row(
            children: [
              ProfileAvatarImage(
                size: 44,
                avatarKey: profile.avatarKey,
                avatarUrl: profile.avatarUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: const Color(0xFF1E3A5F),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Checkbox(
                value: selected,
                activeColor: _teacherTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (_) => onTap(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendInviteButton extends StatelessWidget {
  const _SendInviteButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _teacherCoral,
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          foregroundColor: Colors.white,
          disabledForegroundColor: _teacherMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          context.getText(AppKeys.teacherSendInviteRequest),
          style: GoogleFonts.andika(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({
    required this.scale,
    required this.requests,
  });

  final double scale;
  final List<_FakeClassMember> requests;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 25 * scale,
        vertical: 16 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < requests.length; index++) ...[
            if (index > 0)
              Padding(
                padding: EdgeInsets.only(bottom: 10 * scale),
                child: const Divider(height: 1, color: Color(0xFFF9FAFB)),
              ),
            _JoinRequestRow(scale: scale, request: requests[index]),
            if (index != requests.length - 1) SizedBox(height: 16 * scale),
          ],
        ],
      ),
    );
  }
}

class _JoinRequestRow extends StatelessWidget {
  const _JoinRequestRow({
    required this.scale,
    required this.request,
  });

  final double scale;
  final _FakeClassMember request;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FakeMemberInitialsAvatar(
          member: request,
          size: 40 * scale,
          fontSize: 14 * scale,
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _MemberTextBlock(
            name: request.name,
            status: context.getText(AppKeys.teacherPendingApproval),
            nameFontSize: 16 * scale,
            statusFontSize: 12 * scale,
            nameColor: const Color(0xFF1E3A5F),
            statusColor: _teacherMuted,
          ),
        ),
        SizedBox(width: 10 * scale),
        _RequestActionIcon(
          asset: 'assets/images/teacher_member_accept.png',
          size: 25 * scale,
        ),
        SizedBox(width: 5 * scale),
        _RequestActionIcon(
          asset: 'assets/images/teacher_member_reject.png',
          size: 23 * scale,
        ),
      ],
    );
  }
}

class _RequestActionIcon extends StatelessWidget {
  const _RequestActionIcon({
    required this.asset,
    required this.size,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () {},
      radius: size,
      child: Opacity(
        opacity: 0.8,
        child: Image.asset(
          asset,
          width: size,
          height: size,
        ),
      ),
    );
  }
}

class _JoinedMemberCard extends StatelessWidget {
  const _JoinedMemberCard({
    required this.scale,
    required this.member,
  });

  final double scale;
  final _FakeClassMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 82 * scale),
      padding: EdgeInsets.all(13 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x4DC4C6D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 1 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          _JoinedMemberAvatar(member: member, scale: scale),
          SizedBox(width: 24 * scale),
          Expanded(
            child: _MemberTextBlock(
              name: member.name,
              status: context.getText(member.statusKey),
              nameFontSize: 14 * scale,
              statusFontSize: 12 * scale,
              nameColor: const Color(0xFF181C1E),
              statusColor: const Color(0xFF747781),
              letterSpacing: 0.7 * scale,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: const Color(0xFFC4C6D2),
              size: 20 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinedMemberAvatar extends StatelessWidget {
  const _JoinedMemberAvatar({
    required this.member,
    required this.scale,
  });

  final _FakeClassMember member;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 * scale,
      height: 56 * scale,
      child: Stack(
        children: [
          Positioned.fill(
            child: member.avatarAsset == null
                ? _FakeMemberInitialsAvatar(
                    member: member,
                    size: 56 * scale,
                    fontSize: 24 * scale,
                  )
                : ClipOval(
                    child: Image.asset(
                      member.avatarAsset!,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16 * scale,
              height: 16 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeMemberInitialsAvatar extends StatelessWidget {
  const _FakeMemberInitialsAvatar({
    required this.member,
    required this.size,
    required this.fontSize,
  });

  final _FakeClassMember member;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: member.avatarBackground,
        shape: BoxShape.circle,
        border: Border.all(color: member.avatarBorder),
      ),
      child: Text(
        member.initials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: GoogleFonts.andika(
          color: member.initialsColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _MemberTextBlock extends StatelessWidget {
  const _MemberTextBlock({
    required this.name,
    required this.status,
    required this.nameFontSize,
    required this.statusFontSize,
    required this.nameColor,
    required this.statusColor,
    this.letterSpacing = 0,
  });

  final String name;
  final String status;
  final double nameFontSize;
  final double statusFontSize;
  final Color nameColor;
  final Color statusColor;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: nameColor,
            fontSize: nameFontSize,
            fontWeight: FontWeight.w700,
            height: 1.35,
            letterSpacing: letterSpacing,
          ),
        ),
        Text(
          status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: statusColor,
            fontSize: statusFontSize,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _FakeClassMember {
  const _FakeClassMember({
    required this.name,
    this.statusKey = AppKeys.teacherPendingApproval,
    this.initials = '',
    this.avatarAsset,
    this.avatarBackground = const Color(0xFFF0F7FF),
    this.avatarBorder = Colors.transparent,
    this.initialsColor = const Color(0xFF1E3A5F),
  });

  final String name;
  final String statusKey;
  final String initials;
  final String? avatarAsset;
  final Color avatarBackground;
  final Color avatarBorder;
  final Color initialsColor;
}

bool _isStudentProfile(StudentProfile profile) {
  final role = profile.role?.trim().toUpperCase();
  return role == null || role.isEmpty || role == 'STUDENT';
}

String? _studentSearchSubtitle(BuildContext context, StudentProfile profile) {
  final studentId = profile.studentId?.trim();
  if (studentId != null && studentId.isNotEmpty) {
    return studentId;
  }

  final grade = profile.grade?.label?.trim();
  if (grade != null && grade.isNotEmpty) {
    return grade;
  }

  return null;
}
