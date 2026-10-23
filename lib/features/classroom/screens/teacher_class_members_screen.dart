import 'dart:async';

import 'package:numi/core/data/session_cache_scope.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/controllers/classroom_cubit.dart';
import 'package:numi/features/classroom/controllers/classroom_state.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_exception.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_class_members_content.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_sending_invite_overlay.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_student_invite_search_sheet.dart';

class TeacherClassMembersScreen extends StatefulWidget {
  const TeacherClassMembersScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this._classroomService,
    this._profileService,
  });

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
      widget._classroomService ?? context.read<ClassroomService>();

  final Set<int> _processingProfileIds = <int>{};
  bool _isSendingInvites = false;
  int _identityRevision = 0;

  @override
  void initState() {
    super.initState();
    _loadMembers(forceRefresh: true);
  }

  @override
  void didUpdateWidget(covariant TeacherClassMembersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId ||
        oldWidget.classroomId != widget.classroomId) {
      _identityRevision++;
      _processingProfileIds.clear();
      _isSendingInvites = false;
      _loadMembers(forceRefresh: true);
    }
  }

  Future<void> _loadMembers({bool forceRefresh = false}) {
    return context.read<ClassroomCubit>().loadMembers(
      profileId: widget.profileId,
      classroomId: widget.classroomId,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _handleJoinRequest(
    ClassroomStudent request, {
    required bool approve,
  }) async {
    final targetProfileId = request.profileId;
    if (targetProfileId == null ||
        _processingProfileIds.contains(targetProfileId)) {
      return;
    }
    final identity = _identityRevision;
    final scope = SessionCacheScope.current;
    final profileId = widget.profileId;
    final classroomId = widget.classroomId;
    bool current() =>
        mounted && identity == _identityRevision && scope.isCurrent;
    final cubit = context.read<ClassroomCubit>();
    setState(() => _processingProfileIds.add(targetProfileId));
    try {
      if (approve) {
        await _classroomService.approveJoinRequest(
          profileId: profileId,
          classroomId: classroomId,
          targetProfileId: targetProfileId,
        );
      } else {
        await _classroomService.rejectJoinRequest(
          profileId: profileId,
          classroomId: classroomId,
          targetProfileId: targetProfileId,
        );
      }
      if (!current()) return;
      cubit.invalidateClassroomData(
        profileId: profileId,
        classroomId: classroomId,
        detail: true,
        members: true,
      );
      await cubit.loadMembers(
        profileId: profileId,
        classroomId: classroomId,
        forceRefresh: true,
      );
    } on ClassroomException catch (error) {
      if (!mounted || !current()) {
        return;
      }
      context.showErrorDialog(error.message);
    } finally {
      if (current()) {
        setState(() => _processingProfileIds.remove(targetProfileId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            BlocSelector<ClassroomCubit, ClassroomState, ClassroomMembersState>(
              selector: (state) =>
                  state.members(widget.profileId, widget.classroomId),
              builder: (context, membersState) {
                return TeacherClassMembersContent(
                  isLoading: membersState.isLoading && !membersState.hasLoaded,
                  isSendingInvites: _isSendingInvites,
                  error: membersState.errorMessage,
                  joinRequests: membersState.joinRequests,
                  members: membersState.members,
                  processingProfileIds: _processingProfileIds,
                  onBack: () => Navigator.of(context).maybePop(),
                  onRefresh: () => _loadMembers(forceRefresh: true),
                  onOpenStudentSearch: () => _openStudentSearchSheet(context),
                  onApprove: (request) =>
                      _handleJoinRequest(request, approve: true),
                  onReject: (request) =>
                      _handleJoinRequest(request, approve: false),
                );
              },
            ),
            if (_isSendingInvites) const TeacherSendingInviteOverlay(),
          ],
        ),
      ),
    );
  }

  Future<void> _openStudentSearchSheet(BuildContext context) async {
    if (_isSendingInvites) return;
    final identity = _identityRevision;
    final scope = SessionCacheScope.current;
    final profileId = widget.profileId;
    final classroomId = widget.classroomId;
    bool current() =>
        mounted && identity == _identityRevision && scope.isCurrent;
    final cubit = context.read<ClassroomCubit>();
    final selected = await showModalBottomSheet<List<UserProfile>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => TeacherStudentInviteSearchSheet(
        profileService:
            widget._profileService ?? context.read<ProfileService>(),
      ),
    );
    if (selected == null ||
        selected.isEmpty ||
        !context.mounted ||
        !current()) {
      return;
    }
    final targetProfileIds = selected
        .map(profileStableId)
        .whereType<int>()
        .toList(growable: false);
    if (targetProfileIds.isEmpty) {
      return;
    }
    setState(() => _isSendingInvites = true);
    try {
      await _classroomService.sendInvitations(
        inviterProfileId: profileId,
        classroomId: classroomId,
        targetProfileIds: targetProfileIds,
      );
      if (!current()) return;
      cubit.invalidateClassroomData(
        profileId: profileId,
        classroomId: classroomId,
      );
      await cubit.loadMembers(
        profileId: profileId,
        classroomId: classroomId,
        forceRefresh: true,
      );
    } on ClassroomException catch (error) {
      if (!context.mounted || !current()) {
        return;
      }
      context.showErrorDialog(error.message);
    } finally {
      if (current()) {
        setState(() => _isSendingInvites = false);
      }
    }
  }
}
