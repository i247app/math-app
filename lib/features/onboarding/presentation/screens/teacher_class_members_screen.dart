part of 'teacher_classroom_screens.dart';

class TeacherClassMembersScreen extends StatefulWidget {
  const TeacherClassMembersScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    ClassroomService? classroomService,
    ProfileService? profileService,
  })  : _classroomService = classroomService,
        _profileService = profileService;

  final int classroomId;
  final int profileId;
  final ClassroomService? _classroomService;
  final ProfileService? _profileService;

  @override
  State<TeacherClassMembersScreen> createState() =>
      _TeacherClassMembersScreenState();
}

class _TeacherClassMembersScreenState extends State<TeacherClassMembersScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();

  List<ClassroomStudent> _joinRequests = const <ClassroomStudent>[];
  List<ClassroomStudent> _members = const <ClassroomStudent>[];
  final Set<int> _processingProfileIds = <int>{};
  bool _isLoading = true;
  bool _isSendingInvites = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _classroomService.listJoinRequests(
          profileId: widget.profileId,
          classroomId: widget.classroomId,
        ),
        _classroomService.listStudents(
          profileId: widget.profileId,
          classroomId: widget.classroomId,
        ),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _joinRequests = results[0];
        _members = results[1];
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

  Future<void> _handleJoinRequest(
    ClassroomStudent request, {
    required bool approve,
  }) async {
    final targetProfileId = request.profileId;
    if (targetProfileId == null) {
      return;
    }
    setState(() => _processingProfileIds.add(targetProfileId));
    try {
      if (approve) {
        await _classroomService.approveJoinRequest(
          profileId: widget.profileId,
          classroomId: widget.classroomId,
          targetProfileId: targetProfileId,
        );
      } else {
        await _classroomService.rejectJoinRequest(
          profileId: widget.profileId,
          classroomId: widget.classroomId,
          targetProfileId: targetProfileId,
        );
      }
      await _loadMembers();
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message, style: GoogleFonts.andika()),
            duration: const Duration(milliseconds: 1600),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _processingProfileIds.remove(targetProfileId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teacherPaleMint,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            LayoutBuilder(
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
                      child: RefreshIndicator(
                        color: _teacherTeal,
                        onRefresh: _loadMembers,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
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
                                  onTap: _isSendingInvites
                                      ? null
                                      : () => _openStudentSearchSheet(context),
                                ),
                              ),
                              SizedBox(height: 15 * scale),
                              if (_isLoading &&
                                  _joinRequests.isEmpty &&
                                  _members.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 80 * scale),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: _teacherTeal,
                                    ),
                                  ),
                                )
                              else if (_error != null &&
                                  _joinRequests.isEmpty &&
                                  _members.isEmpty)
                                _TeacherErrorPanel(
                                  scale: scale,
                                  message: _error!,
                                  onRetry: _loadMembers,
                                )
                              else ...[
                                _TeacherMemberSectionTitle(
                                  scale: scale,
                                  title: context.formatText(
                                    AppKeys.teacherJoinRequests,
                                    {'count': _joinRequests.length},
                                  ),
                                ),
                                SizedBox(height: 10 * scale),
                                _JoinRequestCard(
                                  scale: scale,
                                  requests: _joinRequests,
                                  processingProfileIds: _processingProfileIds,
                                  onApprove: (request) => _handleJoinRequest(
                                    request,
                                    approve: true,
                                  ),
                                  onReject: (request) => _handleJoinRequest(
                                    request,
                                    approve: false,
                                  ),
                                ),
                                SizedBox(height: 28 * scale),
                                _TeacherMemberSectionTitle(
                                  scale: scale,
                                  title: context.formatText(
                                    AppKeys.teacherJoinedStudentsTitle,
                                    {'count': _members.length},
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                if (_members.isEmpty)
                                  _TeacherEmptyMemberText(
                                    scale: scale,
                                    text: context.getText(
                                      AppKeys.teacherNoJoinedStudents,
                                    ),
                                  )
                                else
                                  for (var index = 0;
                                      index < _members.length;
                                      index++) ...[
                                    _JoinedMemberCard(
                                      scale: scale,
                                      member: _members[index],
                                    ),
                                    if (index != _members.length - 1)
                                      SizedBox(height: 12 * scale),
                                  ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_isSendingInvites) const _TeacherSendingInviteOverlay(),
          ],
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
        profileService: widget._profileService ?? ProfileApi(),
      ),
    );
    if (selected == null || selected.isEmpty || !context.mounted) {
      return;
    }
    final targetProfileIds = selected
        .map(ActiveProfileSession.profileStableId)
        .whereType<int>()
        .toList(growable: false);
    if (targetProfileIds.isEmpty) {
      return;
    }
    setState(() => _isSendingInvites = true);
    try {
      await _classroomService.sendInvitations(
        inviterProfileId: widget.profileId,
        classroomId: widget.classroomId,
        targetProfileIds: targetProfileIds,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.formatText(
                AppKeys.teacherInviteRequestQueued,
                {'count': targetProfileIds.length},
              ),
              style: GoogleFonts.andika(),
            ),
            duration: const Duration(milliseconds: 1400),
          ),
        );
    } on ClassroomException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message, style: GoogleFonts.andika()),
            duration: const Duration(milliseconds: 1600),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSendingInvites = false);
      }
    }
  }
}

class _TeacherSendingInviteOverlay extends StatelessWidget {
  const _TeacherSendingInviteOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: Colors.black38,
          child: Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(color: _teacherTeal),
              ),
            ),
          ),
        ),
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
  final VoidCallback? onTap;

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
    required this.processingProfileIds,
    required this.onApprove,
    required this.onReject,
  });

  final double scale;
  final List<ClassroomStudent> requests;
  final Set<int> processingProfileIds;
  final ValueChanged<ClassroomStudent> onApprove;
  final ValueChanged<ClassroomStudent> onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return _TeacherEmptyMemberText(
        scale: scale,
        text: context.getText(AppKeys.teacherNoJoinRequests),
      );
    }

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
            _JoinRequestRow(
              scale: scale,
              request: requests[index],
              isProcessing: processingProfileIds.contains(
                requests[index].profileId,
              ),
              onApprove: () => onApprove(requests[index]),
              onReject: () => onReject(requests[index]),
            ),
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
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  final double scale;
  final ClassroomStudent request;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final name = _classroomMemberName(context, request);
    return Row(
      children: [
        _ClassroomMemberAvatar(
          member: request,
          size: 40 * scale,
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _MemberTextBlock(
            name: name,
            status: context.getText(AppKeys.teacherPendingApproval),
            nameFontSize: 16 * scale,
            statusFontSize: 12 * scale,
            nameColor: const Color(0xFF1E3A5F),
            statusColor: _teacherMuted,
          ),
        ),
        SizedBox(width: 10 * scale),
        if (isProcessing)
          SizedBox(
            width: 53 * scale,
            child: Center(
              child: SizedBox(
                width: 18 * scale,
                height: 18 * scale,
                child: const CircularProgressIndicator(
                  color: _teacherTeal,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else ...[
          _RequestActionIcon(
            asset: 'assets/images/teacher_member_accept.png',
            size: 25 * scale,
            onTap: request.profileId == null ? null : onApprove,
          ),
          SizedBox(width: 5 * scale),
          _RequestActionIcon(
            asset: 'assets/images/teacher_member_reject.png',
            size: 23 * scale,
            onTap: request.profileId == null ? null : onReject,
          ),
        ],
      ],
    );
  }
}

class _RequestActionIcon extends StatelessWidget {
  const _RequestActionIcon({
    required this.asset,
    required this.size,
    required this.onTap,
  });

  final String asset;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 0.8,
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
  final ClassroomStudent member;

  @override
  Widget build(BuildContext context) {
    final name = _classroomMemberName(context, member);
    final status = _classroomMemberStatus(context, member);
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
              name: name,
              status: status,
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

  final ClassroomStudent member;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 * scale,
      height: 56 * scale,
      child: Stack(
        children: [
          Positioned.fill(
            child: _ClassroomMemberAvatar(member: member, size: 56 * scale),
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

class _ClassroomMemberAvatar extends StatelessWidget {
  const _ClassroomMemberAvatar({
    required this.member,
    required this.size,
  });

  final ClassroomStudent member;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarImage(
      size: size,
      avatarKey: member.avatarKey,
      avatarUrl: member.avatarUrl,
    );
  }
}

class _TeacherEmptyMemberText extends StatelessWidget {
  const _TeacherEmptyMemberText({
    required this.scale,
    required this.text,
  });

  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 18 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: _teacherMuted,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w600,
          height: 1.35,
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

String _classroomMemberName(BuildContext context, ClassroomStudent member) {
  return _nonEmpty(member.name) ??
      context.getText(AppKeys.teacherStudentFallback);
}

String _classroomMemberStatus(BuildContext context, ClassroomStudent member) {
  final status = _nonEmpty(member.status);
  if (status == null || status.toUpperCase() == 'ACTIVE') {
    return context.getText(AppKeys.teacherJustJoined);
  }
  return status;
}
