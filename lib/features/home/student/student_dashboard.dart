part of '../home_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({
    super.key,
    required this.args,
  });

  final HomeDashboardArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return _StudentHomeContent(
        padding: args.contentPadding,
        scale: args.scale,
        user: args.user,
        profiles: args.profiles,
        activeProfile: args.activeProfile,
        activeRole: ProfileRole.student,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        classroomService: args.classroomService,
        onOpenClassroomTab: args.onOpenClassroomTab,
        onOpenReviewTab: args.onOpenReviewTab,
        onRefreshProfiles: args.onRefreshProfiles,
        onActivateProfile: args.onActivateProfile,
        onProfileSaved: args.onProfileSaved,
        parentHomeEntrance: args.parentHomeEntrance,
        activeRefreshTick: args.activeRefreshTick,
      );
    }

    if (args.activeTab == 1) {
      return _StudentClassroomTab(
        bottomPadding: args.bottomPadding,
        scale: args.scale,
        user: args.user,
        activeProfile: args.activeProfile,
        classroomService: args.classroomService,
        activeRefreshTick: args.activeRefreshTick,
      );
    }

    if (args.activeTab == 2) {
      return ReviewTab(
        user: args.user,
        activeProfile: args.activeProfile,
        isParentMode: false,
        profileLoadError: args.profileLoadError,
        onRefreshProfiles: args.onRefreshProfiles,
        onAddProfile: args.onAddProfileFromReview,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
      );
    }

    if (args.activeTab == 3) {
      return HistoryTab(
        user: args.user,
        activeProfile: args.activeProfile,
        bottomPadding: args.bottomPadding,
        scale: args.scale,
      );
    }

    if (args.activeTab == 4) {
      return _dashboardSettings(args);
    }

    return const SizedBox.shrink();
  }
}

Widget _dashboardSettings(HomeDashboardArgs args) {
  return SettingTab(
    user: args.user,
    profiles: args.profiles,
    activeProfile: args.activeProfile,
    profileLoadError: args.profileLoadError,
    onLogout: args.onLogout,
    onActivateProfile: args.onActivateProfile,
    onRefreshProfiles: args.onRefreshProfiles,
    onProfileSaved: args.onProfileSaved,
    openAddProfileRequestId: args.openAddProfileRequestId,
    bottomPadding: args.bottomPadding,
    scale: args.scale,
  );
}

enum _StudentHomePanel { homework, classroom, achievement }

class _StudentHomeContent extends StatefulWidget {
  const _StudentHomeContent({
    required this.padding,
    required this.scale,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.activeRole,
    required this.initialGrades,
    required this.gradeService,
    required this.classroomService,
    required this.onOpenClassroomTab,
    required this.onOpenReviewTab,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.onProfileSaved,
    required this.parentHomeEntrance,
    this.activeRefreshTick = 0,
  });

  final EdgeInsets padding;
  final double scale;
  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final ClassroomService classroomService;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenReviewTab;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final VoidCallback onProfileSaved;
  final Animation<double> parentHomeEntrance;
  final int activeRefreshTick;

  @override
  State<_StudentHomeContent> createState() => _StudentHomeContentState();
}

class _StudentHomeContentState extends State<_StudentHomeContent> {
  late final ClassroomService _classroomService = widget.classroomService;
  final _StudentHomePanel _activePanel = _StudentHomePanel.homework;
  bool _isLoadingInvitations = false;
  bool _hasLoadedInvitations = false;
  List<ClassroomInvitation> _invitations = const <ClassroomInvitation>[];
  final Set<int> _processingInvitationClassIds = <int>{};

  ClassroomCollectionState get _classroomCollection {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      return const ClassroomCollectionState(profileId: 0);
    }
    return context.read<ClassroomCubit>().joined(profileId);
  }

  List<ClassroomModel> get _classrooms => _classroomCollection.classrooms;

  bool get _isLoadingClassrooms => _classroomCollection.isLoading;

  bool get _hasLoadedClassrooms => _classroomCollection.hasLoaded;

  String? get _classroomError => _classroomCollection.errorMessage == null
      ? null
      : context.readText(AppKeys.studentClassroomLoadFailed);

  @override
  void initState() {
    super.initState();
    if (widget.activeRole == ProfileRole.student) {
      _loadClassrooms();
    }
    _loadInvitations();
  }

  @override
  void didUpdateWidget(covariant _StudentHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final roleChanged = oldWidget.activeRole != widget.activeRole;
    if (oldProfileId != profileId || roleChanged) {
      _invitations = const <ClassroomInvitation>[];
      _hasLoadedInvitations = false;
      if (widget.activeRole == ProfileRole.student) {
        _loadClassrooms();
      }
      _loadInvitations();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      if (widget.activeRole == ProfileRole.student) {
        _loadClassrooms(forceRefresh: true);
      }
      _loadInvitations();
    }
  }

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
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

  Future<void> _loadInvitations() async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0 || _isLoadingInvitations) {
      return;
    }

    setState(() {
      _isLoadingInvitations = true;
    });

    try {
      final invitations = await _classroomService.listMyPendingInvitations(
        profileId: profileId,
      );
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }

      setState(() {
        _hasLoadedInvitations = true;
        _invitations = invitations;
      });
    } catch (_) {
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }

      setState(() {
        _hasLoadedInvitations = true;
        _invitations = const <ClassroomInvitation>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingInvitations = false);
      } else {
        _isLoadingInvitations = false;
      }
    }
  }

  Future<void> _handleInvitation(
    ClassroomInvitation invitation, {
    required bool accept,
  }) async {
    if (!await _allowClassroomActionForActiveRole()) {
      return;
    }

    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final classroomId = invitation.stableClassroomId;
    if (profileId == null || profileId <= 0 || classroomId == null) {
      return;
    }
    final inviterProfileId = invitation.inviterProfileId ?? profileId;

    setState(() => _processingInvitationClassIds.add(classroomId));
    try {
      if (accept) {
        await _classroomService.acceptInvitation(
          inviteeProfileId: profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
      } else {
        await _classroomService.rejectInvitation(
          inviteeProfileId: profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.readText(
                accept
                    ? AppKeys.studentInvitationAcceptSuccess
                    : AppKeys.studentInvitationRejectSuccess,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      await _loadInvitations();
      if (accept) {
        await _loadClassrooms(forceRefresh: true);
      }
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _processingInvitationClassIds.remove(classroomId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId != null && profileId > 0) {
      context.select<ClassroomCubit, ClassroomCollectionState>(
        (cubit) => cubit.joined(profileId),
      );
    }
    final isLoadingHomeSections = profileId != null &&
        profileId > 0 &&
        (!_hasLoadedInvitations ||
            (widget.activeRole == ProfileRole.student &&
                !_hasLoadedClassrooms));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.activeRole == ProfileRole.parent)
            _HomePopIn(
              animation: widget.parentHomeEntrance,
              interval: const Interval(0, 0.62),
              beginOffset: const Offset(0, 22),
              beginScale: 0.92,
              child: _StudentFigmaHeroCard(
                onAssessmentTap: () =>
                    _openGradeSelection(quizPurposeAssessment),
              ),
            )
          else
            _StudentFigmaHeroCard(
              onAssessmentTap: () => _openGradeSelection(quizPurposeAssessment),
            ),
          const SizedBox(height: 22),
          if (widget.activeRole == ProfileRole.parent)
            _HomePopIn(
              animation: widget.parentHomeEntrance,
              interval: const Interval(0.3, 1),
              beginOffset: const Offset(0, 26),
              beginScale: 0.9,
              child: _ParentWelcomeMapCard(
                onTap: widget.onOpenReviewTab,
              ),
            )
          else if (isLoadingHomeSections)
            const _StudentHomeSectionsLoading()
          else ...[
            _StudentInvitationsSection(
              invitations: _invitations,
              processingClassroomIds: _processingInvitationClassIds,
              showJoinClassroom: widget.activeRole == ProfileRole.student &&
                  _classrooms.isEmpty,
              onJoinClassroom: widget.activeRole == ProfileRole.student
                  ? widget.onOpenClassroomTab
                  : _handleParentClassroomEntry,
              onViewAll: _openAllInvitations,
              onAccept: (invitation) => _handleInvitation(
                invitation,
                accept: true,
              ),
              onReject: (invitation) => _handleInvitation(
                invitation,
                accept: false,
              ),
            ),
            if (widget.activeRole == ProfileRole.student) ...[
              if (_classrooms.isNotEmpty ||
                  !_hasLoadedClassrooms ||
                  _classroomError != null) ...[
                const SizedBox(height: 11),
                _StudentClassGridSection(
                  classrooms: _classrooms,
                  isLoading: _isLoadingClassrooms && !_hasLoadedClassrooms,
                  isRefreshing: _isLoadingClassrooms && _classrooms.isNotEmpty,
                  error: _classroomError,
                  onOpenClassroom: _openClassDetail,
                  onViewAll: widget.onOpenClassroomTab,
                ),
              ],
            ],
            const SizedBox(height: 20),
            const _HomeTeacherMessages(),
          ],
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPanel(BuildContext context) {
    return switch (_activePanel) {
      _StudentHomePanel.homework => _HomeworkPanel(
          key: const ValueKey(_StudentHomePanel.homework),
          scale: widget.scale,
        ),
      _StudentHomePanel.classroom => _StudentClassroomPanel(
          key: const ValueKey(_StudentHomePanel.classroom),
          scale: widget.scale,
          classrooms: _classrooms,
          isLoading: _isLoadingClassrooms,
          error: _classroomError,
          onRetry: _refreshClassrooms,
          onJoinClassroom: widget.activeRole == ProfileRole.student
              ? widget.onOpenClassroomTab
              : _handleParentClassroomEntry,
        ),
      _StudentHomePanel.achievement => _AchievementPanel(
          key: const ValueKey(_StudentHomePanel.achievement),
          scale: widget.scale,
        ),
    };
  }

  Future<void> _handleParentClassroomEntry() async {
    await _allowClassroomActionForActiveRole();
  }

  Future<void> _openAllInvitations() async {
    if (!await _allowClassroomActionForActiveRole()) {
      return;
    }
    if (!mounted) {
      return;
    }

    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.studentMissingProfileId)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    final acceptedInvitation = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _StudentInvitationListScreen(
          profileId: profileId,
          classroomService: _classroomService,
          initialInvitations: _invitations,
        ),
      ),
    );
    await _loadInvitations();
    if (acceptedInvitation == true) {
      await _loadClassrooms(forceRefresh: true);
    }
  }

  Future<bool> _allowClassroomActionForActiveRole() async {
    if (widget.activeRole != ProfileRole.parent) {
      return true;
    }

    if (_studentProfiles.isEmpty) {
      await widget.onRefreshProfiles();
      if (!mounted) {
        return false;
      }
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) {
        return false;
      }
    }

    if (_studentProfiles.isNotEmpty) {
      final shouldSwitch = await _showParentSwitchStudentDialog();
      if (shouldSwitch == true && mounted) {
        await _openProfileSwitch();
      }
      return false;
    }

    final shouldCreateStudent = await _showParentNoStudentDialog();
    if (!mounted) {
      return false;
    }
    if (shouldCreateStudent == true) {
      await _openCreateStudentProfile();
    }
    return false;
  }

  List<StudentProfile> get _studentProfiles {
    return widget.profiles
        .where((profile) =>
            ProfileRole.fromProfile(profile) == ProfileRole.student)
        .toList();
  }

  Future<void> _openProfileSwitch() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Material(
          color: Colors.white,
          child: SafeArea(
            child: SettingTab.page(
              user: widget.user,
              profiles: widget.profiles,
              activeProfile: widget.activeProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: widget.onActivateProfile,
              onRefreshProfiles: widget.onRefreshProfiles,
              onProfileSaved: widget.onProfileSaved,
              bottomPadding: 0,
              scale: widget.scale,
              initialView: SettingPageView.profile,
              isPushedPage: true,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateStudentProfile() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Material(
          color: Colors.white,
          child: SafeArea(
            child: SettingTab.page(
              user: widget.user,
              profiles: widget.profiles,
              activeProfile: widget.activeProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: widget.onActivateProfile,
              onRefreshProfiles: widget.onRefreshProfiles,
              onProfileSaved: widget.onProfileSaved,
              bottomPadding: 0,
              scale: widget.scale,
              initialView: SettingPageView.profile,
              isPushedPage: true,
              openAddProfileOnStart: true,
            ),
          ),
        ),
      ),
    );
    await widget.onRefreshProfiles();
  }

  Future<bool?> _showParentSwitchStudentDialog() {
    HapticFeedback.selectionClick();
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            context.getText(AppKeys.parentSwitchStudentTitle),
            style: const TextStyle(
              color: Color(0xFF001741),
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          content: Text(
            context.getText(AppKeys.parentSwitchStudentMessage),
            style: const TextStyle(
              color: Color(0xFF444650),
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.getText(AppKeys.cancel)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
              ),
              child: Text(
                context.getText(AppKeys.parentSwitchStudentAction),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showParentNoStudentDialog() {
    HapticFeedback.selectionClick();
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF001741).withValues(alpha: 0.40),
      builder: (_) => const _ParentNoStudentDialog(),
    );
  }

  void _openGradeSelection(String quizPurpose) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GradeSelectionScreen(
          user: widget.user,
          initialGrades: widget.initialGrades,
          gradeService: widget.gradeService,
          quizPurpose: quizPurpose,
          profileId: ActiveProfileSession.profileStableId(
            widget.activeProfile,
          ),
          initialGradeId: _profileGradeId(widget.activeProfile),
          initialGradeLabel: widget.activeProfile?.grade?.label,
        ),
      ),
    );
  }

  Future<void> _openClassDetail(ClassroomModel classroom) async {
    if (!await _allowClassroomActionForActiveRole()) {
      return;
    }
    if (!mounted) {
      return;
    }

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
}

int? _profileGradeId(StudentProfile? profile) =>
    profile?.grade?.gradeId ?? profile?.grade?.id ?? profile?.gradeId;

class _StudentInvitationsSection extends StatelessWidget {
  const _StudentInvitationsSection({
    required this.invitations,
    required this.processingClassroomIds,
    required this.showJoinClassroom,
    required this.onJoinClassroom,
    required this.onViewAll,
    required this.onAccept,
    required this.onReject,
  });

  final List<ClassroomInvitation> invitations;
  final Set<int> processingClassroomIds;
  final bool showJoinClassroom;
  final VoidCallback onJoinClassroom;
  final VoidCallback onViewAll;
  final ValueChanged<ClassroomInvitation> onAccept;
  final ValueChanged<ClassroomInvitation> onReject;

  @override
  Widget build(BuildContext context) {
    final invitation = invitations.isNotEmpty ? invitations.first : null;
    final showInvitationPreview = invitation != null;
    if (!showInvitationPreview && !showJoinClassroom) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showInvitationPreview) ...[
            _StudentFigmaSectionHeader(
              title: context.getText(AppKeys.studentClassInvitations),
              actionLabel: context.formatText(
                AppKeys.studentViewAllInvitations,
                {'count': invitations.length},
              ),
              onAction: onViewAll,
            ),
            const SizedBox(height: 10),
            _StudentInvitationCard(
              invitation: invitation,
              isProcessing: processingClassroomIds.contains(
                invitation.stableClassroomId,
              ),
              compactActions: true,
              onAccept: () => onAccept(invitation),
              onReject: () => onReject(invitation),
            ),
            const SizedBox(height: 6),
          ],
          if (showJoinClassroom) _StudentJoinClassCta(onTap: onJoinClassroom),
        ],
      ),
    );
  }
}

class _StudentHomeSectionsLoading extends StatelessWidget {
  const _StudentHomeSectionsLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _teal),
            const SizedBox(height: 14),
            Text(
              context.getText(AppKeys.loading),
              style: const TextStyle(
                color: Color(0xFF30333A),
                fontSize: FontSize.small,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentNoStudentDialog extends StatelessWidget {
  const _ParentNoStudentDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: 303,
            padding: const EdgeInsets.fromLTRB(25, 32, 25, 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 192,
                      height: 192,
                      decoration: BoxDecoration(
                        color: const Color(0xFFAA2A6C).withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFAA2A6C).withValues(alpha: 0.16),
                            blurRadius: 30,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      _parentNoStudentMascot,
                      width: 220,
                      height: 198,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  context.getText(AppKeys.parentNoStudentTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF001741),
                    fontSize: FontSize.title,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.getText(AppKeys.parentNoStudentMessage),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF444650),
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFAA2A6C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.getText(AppKeys.parentCreateStudentNow),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFAA2A6C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      context.getText(AppKeys.parentCreateStudentLater),
                      style: const TextStyle(
                        color: Color(0xFFAA2A6C),
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0,
                      ),
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

class _StudentInlineErrorPanel extends StatelessWidget {
  const _StudentInlineErrorPanel({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF444650),
                fontSize: FontSize.caption,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(context.getText(AppKeys.studentRetry)),
          ),
        ],
      ),
    );
  }
}

class _StudentFigmaSectionHeader extends StatelessWidget {
  const _StudentFigmaSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final action = Text(
      actionLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFFBC3B14),
        fontSize: FontSize.small,
        fontWeight: FontWeight.w900,
        decoration: TextDecoration.underline,
        height: 1.2,
        letterSpacing: 0,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF001741),
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w900,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (onAction == null)
          action
        else
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onAction!();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: action,
            ),
          ),
      ],
    );
  }
}

class _StudentInvitationCard extends StatelessWidget {
  const _StudentInvitationCard({
    required this.invitation,
    required this.isProcessing,
    this.compactActions = false,
    required this.onAccept,
    required this.onReject,
  });

  final ClassroomInvitation invitation;
  final bool isProcessing;
  final bool compactActions;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final classroom = invitation.classroom;
    final title = classroom?.name?.trim().isNotEmpty == true
        ? classroom!.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final inviterName = invitation.inviterName?.trim();
    final subtitle = inviterName != null && inviterName.isNotEmpty
        ? context.formatText(
            AppKeys.studentInviteSubtitle,
            {'name': inviterName},
          )
        : context.getText(AppKeys.studentInviteSubtitleFallback);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: compactActions
          ? _buildCompact(context, title, subtitle)
          : Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      _studentHomeInvite,
                      width: 36,
                      height: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF181C1E),
                              fontSize: FontSize.normal,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF444650),
                              fontSize: FontSize.caption,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                if (isProcessing)
                  const SizedBox(
                    height: 27,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: _teal,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _StudentInviteButton(
                          label: context.getText(AppKeys.accept),
                          color: const Color(0xFF38898C),
                          onTap: onAccept,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StudentInviteButton(
                          label: context.getText(AppKeys.reject),
                          color: const Color(0xFFF37850),
                          onTap: onReject,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _buildCompact(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF001741),
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF001741).withValues(alpha: 0.7),
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (isProcessing)
          const SizedBox(
            width: 56,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: _teal,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StudentInviteIconButton(
                asset: _studentParentHomeAcceptIcon,
                label: context.getText(AppKeys.accept),
                onTap: onAccept,
              ),
              const SizedBox(width: 8),
              _StudentInviteIconButton(
                asset: _studentParentHomeRejectIcon,
                label: context.getText(AppKeys.reject),
                onTap: onReject,
              ),
            ],
          ),
      ],
    );
  }
}

class _StudentInviteIconButton extends StatelessWidget {
  const _StudentInviteIconButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: Image.asset(asset, width: 25, height: 25),
      ),
    );
  }
}

class _StudentInviteButton extends StatelessWidget {
  const _StudentInviteButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27,
      child: FilledButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: FontSize.caption,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _StudentFigmaHeroCard extends StatelessWidget {
  const _StudentFigmaHeroCard({required this.onAssessmentTap});

  final VoidCallback onAssessmentTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 225,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFFEDF7F6),
            Color(0xFFF7CFC3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -14,
            right: -14,
            bottom: -48,
            child: Opacity(
              opacity: 0.70,
              child: Image.asset(
                _studentParentHomeHeroBg,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 35,
            right: 35,
            top: 23,
            child: Text(
              context.getText(AppKeys.homeHeroTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF357476),
                fontSize: FontSize.title,
                fontWeight: FontWeight.w900,
                height: 1.5,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Positioned(
            left: 35,
            right: 35,
            top: 65,
            child: Text(
              context.getText(AppKeys.homeHeroSubtitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF001741),
                fontSize: FontSize.large,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ),
          Positioned(
            right: -10,
            top: 18,
            width: 80,
            child: Transform.rotate(
              angle: 0.785398,
              child: Text(
                context.getText(AppKeys.homeHeroTextbookLabel),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD95F42),
                  fontSize: FontSize.caption * 0.7,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          Positioned(
            right: -13,
            bottom: 0,
            width: 202,
            height: 135,
            child: Image.asset(_studentParentHomeHeroArt, fit: BoxFit.contain),
          ),
          Positioned(
            left: 9,
            bottom: 37,
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    context.getText(AppKeys.homeHeroPrompt),
                    style: const TextStyle(
                      color: Color(0xFF001741),
                      fontSize: FontSize.caption,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      height: 1.15,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                _HeroActionButton(
                  label: context.getText(AppKeys.homeHeroAssessment),
                  color: const Color(0xFFFB7651),
                  icon: _studentParentHomeAssessmentIcon,
                  onTap: onAssessmentTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentWelcomeMapCard extends StatelessWidget {
  const _ParentWelcomeMapCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: double.infinity,
            height: 250,
            child: Ink.image(
              image: const AssetImage(_parentHomeWelcomeMap),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomePopIn extends StatelessWidget {
  const _HomePopIn({
    required this.child,
    required this.animation,
    required this.interval,
    required this.beginOffset,
    this.beginScale = 0.92,
  });

  final Widget child;
  final Animation<double> animation;
  final Interval interval;
  final Offset beginOffset;
  final double beginScale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: RepaintBoundary(child: child),
      builder: (context, child) {
        final intervalValue = interval.transform(animation.value);
        final fadeValue = Curves.easeOut.transform(intervalValue);
        final moveValue = Curves.easeOutCubic.transform(intervalValue);
        final scaleValue = Curves.easeOutBack.transform(intervalValue);

        return Opacity(
          opacity: fadeValue,
          child: Transform.translate(
            offset: Offset.lerp(beginOffset, Offset.zero, moveValue)!,
            child: Transform.scale(
              scale: beginScale + ((1 - beginScale) * scaleValue),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 6),
            SvgPicture.asset(icon, width: 16, height: 16),
          ],
        ),
      ),
    );
  }
}

class _StudentJoinClassCta extends StatelessWidget {
  const _StudentJoinClassCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFAA2A6C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              _studentParentHomeJoinIcon,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 7),
            Text(
              context.getText(AppKeys.studentJoinClassroomUpper),
              style: const TextStyle(
                color: Colors.white,
                fontSize: FontSize.small,
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentClassGridSection extends StatelessWidget {
  const _StudentClassGridSection({
    required this.classrooms,
    required this.isLoading,
    required this.isRefreshing,
    required this.error,
    required this.onOpenClassroom,
    required this.onViewAll,
  });

  final List<ClassroomModel> classrooms;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final ValueChanged<ClassroomModel> onOpenClassroom;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final visibleClassrooms = classrooms.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StudentFigmaSectionHeader(
          title: context.getText(AppKeys.teacherYourClasses),
          actionLabel: context.formatText(
            AppKeys.studentViewAllClassrooms,
            {'count': classrooms.length},
          ),
          onAction: classrooms.isEmpty ? null : onViewAll,
        ),
        const SizedBox(height: 10),
        if (isLoading && classrooms.isEmpty)
          const _StudentFigmaStateCard(
            titleKey: AppKeys.loading,
            messageKey: AppKeys.studentClassroomLoadFailed,
          )
        else if (error != null && classrooms.isEmpty)
          _StudentFigmaStateCard(title: error!, messageKey: AppKeys.retry)
        else if (visibleClassrooms.isEmpty)
          const _StudentFigmaStateCard(
            titleKey: AppKeys.studentNoClassroomsTitle,
            messageKey: AppKeys.studentNoClassroomsMessage,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 78,
            ),
            itemCount: visibleClassrooms.length,
            itemBuilder: (context, index) {
              return _StudentFigmaClassCard(
                classroom: visibleClassrooms[index],
                onTap: () => onOpenClassroom(visibleClassrooms[index]),
              );
            },
          ),
        if (isRefreshing) const _StudentHomeRefreshLabel(),
      ],
    );
  }
}

class _StudentHomeRefreshLabel extends StatelessWidget {
  const _StudentHomeRefreshLabel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        context.getText(AppKeys.loading),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _muted,
          fontSize: FontSize.caption,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StudentFigmaStateCard extends StatelessWidget {
  const _StudentFigmaStateCard({
    this.title,
    this.titleKey,
    required this.messageKey,
  });

  final String? title;
  final String? titleKey;
  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              _studentParentHomeClassThumb,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title ?? context.getText(titleKey!),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.getText(messageKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF002B6A).withValues(alpha: 0.6),
              fontSize: FontSize.caption * 0.85,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentFigmaClassCard extends StatelessWidget {
  const _StudentFigmaClassCard({
    required this.classroom,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final teacher = classroom.teacherName?.trim().isNotEmpty == true
        ? classroom.teacherName!.trim()
        : context.getText(AppKeys.teacherFallback);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD7DCE5),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF002B6A).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF073E45),
                  fontSize: FontSize.title,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                teacher,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF357476).withValues(alpha: 0.72),
                  fontSize: FontSize.caption * 0.77,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTeacherMessages extends StatelessWidget {
  const _HomeTeacherMessages();

  @override
  Widget build(BuildContext context) {
    const messages = <_HomeTeacherMessageData>[
      _HomeTeacherMessageData(
        avatarAsset: _homeTeacherAvatarOne,
        teacherKey: AppKeys.homeMessageTeacherOne,
        classKey: AppKeys.homeMessageClassOne,
        timeKey: AppKeys.homeMessageTimeOne,
        studentKey: AppKeys.homeMessageStudentOne,
        bodyKey: AppKeys.homeMessageBodyOne,
        accentColor: Color(0xFFB52B70),
        badgeColor: Color(0xFFF1C6DB),
      ),
      _HomeTeacherMessageData(
        avatarAsset: _homeTeacherAvatarTwo,
        teacherKey: AppKeys.homeMessageTeacherTwo,
        classKey: AppKeys.homeMessageClassTwo,
        timeKey: AppKeys.homeMessageTimeTwo,
        studentKey: AppKeys.homeMessageStudentTwo,
        bodyKey: AppKeys.homeMessageBodyTwo,
        accentColor: Color(0xFF002B6A),
        badgeColor: Color(0xFFC8D6F2),
      ),
    ];

    return Column(
      children: [
        for (var index = 0; index < messages.length; index++) ...[
          _HomeTeacherMessageCard(data: messages[index]),
          if (index != messages.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HomeTeacherMessageData {
  const _HomeTeacherMessageData({
    required this.avatarAsset,
    required this.teacherKey,
    required this.classKey,
    required this.timeKey,
    required this.studentKey,
    required this.bodyKey,
    required this.accentColor,
    required this.badgeColor,
  });

  final String avatarAsset;
  final String teacherKey;
  final String classKey;
  final String timeKey;
  final String studentKey;
  final String bodyKey;
  final Color accentColor;
  final Color badgeColor;
}

class _HomeTeacherMessageCard extends StatelessWidget {
  const _HomeTeacherMessageCard({required this.data});

  final _HomeTeacherMessageData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE1E8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002B6A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      data.avatarAsset,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: data.badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        size: 11,
                        color: data.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.getText(data.teacherKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF001741),
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.getText(data.classKey),
                      style: const TextStyle(
                        color: Color(0xFF515F6F),
                        fontSize: FontSize.caption * 0.85,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.getText(data.timeKey),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: FontSize.caption * 0.85,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFB9C0CE),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: data.accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.getText(data.studentKey),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSize.caption * 0.7,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.getText(data.bodyKey),
                  style: const TextStyle(
                    color: Color(0xFF30333A),
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
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

class _StudentClassroomTab extends StatefulWidget {
  const _StudentClassroomTab({
    required this.bottomPadding,
    required this.scale,
    required this.user,
    required this.activeProfile,
    required this.classroomService,
    this.activeRefreshTick = 0,
  });

  final double bottomPadding;
  final double scale;
  final LoginUser? user;
  final StudentProfile? activeProfile;
  final ClassroomService classroomService;
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
    _loadClassrooms();
  }

  @override
  void didUpdateWidget(covariant _StudentClassroomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
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
          _StudentClassroomHeader(scale: scale, topInset: topInset),
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
                            const _StudentFigmaStateCard(
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

class _StudentClassroomHeader extends StatelessWidget {
  const _StudentClassroomHeader({
    required this.scale,
    required this.topInset,
  });

  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: topInset + 60 * scale,
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF2F2F2),
            width: 4 * scale,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        context.getText(AppKeys.studentClassroom),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: const Color(0xFF339395),
          fontSize: FontSize.title,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _StudentClassroomLoadingRegion extends StatelessWidget {
  const _StudentClassroomLoadingRegion();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _teal),
            const SizedBox(height: 14),
            Text(
              context.getText(AppKeys.loading),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF30333A),
                fontSize: FontSize.small,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentClassroomTabCard extends StatelessWidget {
  const _StudentClassroomTabCard({
    required this.classroom,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final teacher = classroom.teacherName?.trim().isNotEmpty == true
        ? classroom.teacherName!.trim()
        : context.getText(AppKeys.teacherFallback);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 22, 12, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD4D8E3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF002B6A).withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF002B6A),
                  fontSize: FontSize.title,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 14),
              _StudentClassroomMetaRow(
                icon: Icons.person_rounded,
                label: teacher,
              ),
              const SizedBox(height: 7),
              _StudentClassroomMetaRow(
                icon: Icons.groups_rounded,
                label: context.formatText(
                  AppKeys.teacherStudentCount,
                  {'count': classroom.displayStudentCount},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentClassroomMetaRow extends StatelessWidget {
  const _StudentClassroomMetaRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF747781)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF747781),
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentJoinAnotherClassroomTitle extends StatelessWidget {
  const _StudentJoinAnotherClassroomTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF1EBFA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF6647E8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.getText(AppKeys.studentJoinAnotherClassroom),
              style: const TextStyle(
                color: Color(0xFF002B6A),
                fontSize: FontSize.large,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentInvitationListScreen extends StatefulWidget {
  const _StudentInvitationListScreen({
    required this.profileId,
    required this.classroomService,
    required this.initialInvitations,
  });

  final int profileId;
  final ClassroomService classroomService;
  final List<ClassroomInvitation> initialInvitations;

  @override
  State<_StudentInvitationListScreen> createState() =>
      _StudentInvitationListScreenState();
}

class _StudentInvitationListScreenState
    extends State<_StudentInvitationListScreen> {
  List<ClassroomInvitation> _invitations = const <ClassroomInvitation>[];
  final Set<int> _processingClassroomIds = <int>{};
  bool _isLoading = false;
  bool _acceptedInvitation = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _invitations = widget.initialInvitations;
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invitations = await widget.classroomService
          .listMyPendingInvitations(profileId: widget.profileId);
      if (!mounted) {
        return;
      }
      setState(() => _invitations = invitations);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = context.readText(AppKeys.studentInvitationLoadFailed);
        _invitations = const <ClassroomInvitation>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      } else {
        _isLoading = false;
      }
    }
  }

  Future<void> _handleInvitation(
    ClassroomInvitation invitation, {
    required bool accept,
  }) async {
    final classroomId = invitation.stableClassroomId;
    if (classroomId == null) {
      return;
    }

    final inviterProfileId = invitation.inviterProfileId ?? widget.profileId;
    setState(() => _processingClassroomIds.add(classroomId));
    try {
      if (accept) {
        await widget.classroomService.acceptInvitation(
          inviteeProfileId: widget.profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
        _acceptedInvitation = true;
      } else {
        await widget.classroomService.rejectInvitation(
          inviteeProfileId: widget.profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.readText(
                accept
                    ? AppKeys.studentInvitationAcceptSuccess
                    : AppKeys.studentInvitationRejectSuccess,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      await _loadInvitations();
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _processingClassroomIds.remove(classroomId));
      }
    }
  }

  void _close() {
    Navigator.of(context).pop(_acceptedInvitation);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(context.getText(AppKeys.studentClassInvitations)),
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _loadInvitations,
            color: _teal,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                if (_isLoading && _invitations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child:
                        Center(child: CircularProgressIndicator(color: _teal)),
                  )
                else if (_error != null && _invitations.isEmpty)
                  _StudentInlineErrorPanel(
                    message: _error!,
                    onRetry: _loadInvitations,
                  )
                else if (_invitations.isEmpty)
                  const _StudentFigmaStateCard(
                    titleKey: AppKeys.studentNoInvitationsTitle,
                    messageKey: AppKeys.studentNoInvitationsMessage,
                  )
                else
                  for (var index = 0; index < _invitations.length; index++) ...[
                    _StudentInvitationCard(
                      invitation: _invitations[index],
                      isProcessing: _processingClassroomIds.contains(
                        _invitations[index].stableClassroomId,
                      ),
                      onAccept: () => _handleInvitation(
                        _invitations[index],
                        accept: true,
                      ),
                      onReject: () => _handleInvitation(
                        _invitations[index],
                        accept: false,
                      ),
                    ),
                    if (index != _invitations.length - 1)
                      const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _StudentHomeTabs extends StatelessWidget {
  const _StudentHomeTabs({
    required this.activePanel,
    required this.scale,
    required this.onChanged,
  });

  final _StudentHomePanel activePanel;
  final double scale;
  final ValueChanged<_StudentHomePanel> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = <(_StudentHomePanel, String)>[
      (_StudentHomePanel.homework, context.getText(AppKeys.studentHomework)),
      (_StudentHomePanel.classroom, context.getText(AppKeys.studentClassroom)),
      (_StudentHomePanel.achievement, context.getText(AppKeys.yourAchievement)),
    ];
    final activeIndex = tabs.indexWhere((tab) => tab.$1 == activePanel);

    return Container(
      padding: EdgeInsets.all(5 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;

          return SizedBox(
            height: 42 * scale,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: tabWidth * activeIndex,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _teal,
                      borderRadius: BorderRadius.circular(20 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: _teal.withValues(alpha: 0.18),
                          blurRadius: 12 * scale,
                          offset: Offset(0, 6 * scale),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final tab in tabs)
                      Expanded(
                        child: _StudentHomeTabButton(
                          label: tab.$2,
                          selected: tab.$1 == activePanel,
                          scale: scale,
                          onTap: () => onChanged(tab.$1),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StudentHomeTabButton extends StatelessWidget {
  const _StudentHomeTabButton({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20 * scale),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20 * scale),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 42 * scale,
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontSize: FontSize.caption * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeworkPanel extends StatelessWidget {
  const _HomeworkPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _StudentEmptyPanel(
      scale: scale,
      icon: Icons.assignment_rounded,
      title: context.getText(AppKeys.studentNoHomeworkTitle),
      message: context.getText(AppKeys.studentNoHomeworkMessage),
    );
  }
}

class _StudentClassroomPanel extends StatelessWidget {
  const _StudentClassroomPanel({
    super.key,
    required this.scale,
    required this.classrooms,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onJoinClassroom,
  });

  final double scale;
  final List<ClassroomModel> classrooms;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onJoinClassroom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _JoinClassroomButton(
            scale: scale,
            onTap: onJoinClassroom,
          ),
        ),
        SizedBox(height: 14 * scale),
        if (isLoading && classrooms.isEmpty)
          _StudentLoadingPanel(scale: scale)
        else if (error != null && classrooms.isEmpty)
          _StudentErrorPanel(
            scale: scale,
            message: error!,
            onRetry: onRetry,
          )
        else if (classrooms.isEmpty)
          _StudentEmptyPanel(
            scale: scale,
            icon: Icons.groups_rounded,
            title: context.getText(AppKeys.studentNoClassroomsTitle),
            message: context.getText(AppKeys.studentNoClassroomsMessage),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < classrooms.length; index++) ...[
                _StudentClassroomCard(
                  scale: scale,
                  classroom: classrooms[index],
                ),
                if (index != classrooms.length - 1)
                  SizedBox(height: 12 * scale),
              ],
            ],
          ),
      ],
    );
  }
}

class _JoinClassroomButton extends StatelessWidget {
  const _JoinClassroomButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF7B54),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 11 * scale,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18 * scale),
              SizedBox(width: 6 * scale),
              Text(
                context.getText(AppKeys.studentJoinNewClassroom),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: FontSize.caption * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentClassroomCard extends StatelessWidget {
  const _StudentClassroomCard({
    required this.scale,
    required this.classroom,
  });

  final double scale;
  final ClassroomModel classroom;

  @override
  Widget build(BuildContext context) {
    final title = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final description = classroom.description?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56 * scale,
            height: 56 * scale,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22 * scale),
            ),
            child: Icon(
              Icons.school_rounded,
              color: _teal,
              size: 27 * scale,
            ),
          ),
          SizedBox(width: 15 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _deepInk,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  description != null && description.isNotEmpty
                      ? description
                      : context.formatText(
                          AppKeys.teacherStudentCount,
                          {'count': classroom.displayStudentCount},
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          Icon(
            Icons.chevron_right_rounded,
            color: _teal,
            size: 26 * scale,
          ),
        ],
      ),
    );
  }
}

class _AchievementPanel extends StatelessWidget {
  const _AchievementPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('achievement_panel_content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AchievementsHeader(scale: scale),
        SizedBox(height: 20 * scale),
        _AchievementCard(scale: scale),
      ],
    );
  }
}

class _StudentLoadingPanel extends StatelessWidget {
  const _StudentLoadingPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 132 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: SizedBox(
        width: 26 * scale,
        height: 26 * scale,
        child: const CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}

class _StudentErrorPanel extends StatelessWidget {
  const _StudentErrorPanel({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StudentMessagePanel(
      scale: scale,
      icon: Icons.wifi_off_rounded,
      title: message,
      message: context.getText(AppKeys.retry),
      actionLabel: context.getText(AppKeys.retryUpper),
      onAction: onRetry,
    );
  }
}

class _StudentEmptyPanel extends StatelessWidget {
  const _StudentEmptyPanel({
    required this.scale,
    required this.icon,
    required this.title,
    required this.message,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _StudentMessagePanel(
      scale: scale,
      icon: icon,
      title: title,
      message: message,
    );
  }
}

class _StudentMessagePanel extends StatelessWidget {
  const _StudentMessagePanel({
    required this.scale,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(30 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58 * scale,
            height: 58 * scale,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24 * scale),
            ),
            child: Icon(icon, color: _teal, size: 28 * scale),
          ),
          SizedBox(height: 14 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _deepInk,
              fontSize: FontSize.normal * scale,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grayText,
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 16 * scale),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _AchievementsHeader extends StatelessWidget {
  const _AchievementsHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.getText(AppKeys.yourAchievement),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _deepInk,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 10 * scale),
              Container(
                width: 48 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFA03A0F).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 3 * scale),
          child: Text(
            context.getText(AppKeys.viewAllUpper),
            style: TextStyle(
              color: _teal,
              fontSize: FontSize.caption * 0.85 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104 * scale,
      padding: EdgeInsets.all(21 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(32 * scale),
        border:
            Border.all(color: const Color(0xFFA2B1A3).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64 * scale,
            height: 64 * scale,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28 * scale),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _teal,
              size: 28 * scale,
            ),
          ),
          SizedBox(width: 20 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getText(AppKeys.progressAchievementTitle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _deepInk,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  context.getText(AppKeys.todayCompletedExercises),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: const BoxDecoration(
              color: Color(0xFFDBEDDC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: _teal,
              size: 24 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
