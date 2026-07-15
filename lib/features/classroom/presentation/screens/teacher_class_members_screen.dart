import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/application/classroom_cubit.dart';
import 'package:numi/features/classroom/application/classroom_state.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_class_members_content.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_sending_invite_overlay.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_student_invite_search_sheet.dart';

class TeacherClassMembersScreen extends StatefulWidget {
  const TeacherClassMembersScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    ClassroomService? classroomService,
    ProfileService? profileService,
  }) : _classroomService = classroomService,
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

  final Set<int> _processingProfileIds = <int>{};
  bool _isSendingInvites = false;

  @override
  void initState() {
    super.initState();
    _loadMembers(forceRefresh: true);
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
    if (targetProfileId == null) {
      return;
    }
    final cubit = context.read<ClassroomCubit>();
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
      cubit.invalidateClassroomData(
        profileId: widget.profileId,
        classroomId: widget.classroomId,
        detail: true,
        members: false,
      );
      await cubit.loadMembers(
        profileId: widget.profileId,
        classroomId: widget.classroomId,
        forceRefresh: true,
      );
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorDialog(error.message);
    } finally {
      if (mounted) {
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
            LayoutBuilder(
              builder: (context, constraints) {
                final scale = math.min(constraints.maxWidth / 390, 1.12);
                return BlocSelector<
                  ClassroomCubit,
                  ClassroomState,
                  ClassroomMembersState
                >(
                  selector: (state) =>
                      state.members(widget.profileId, widget.classroomId),
                  builder: (context, membersState) {
                    return TeacherClassMembersContent(
                      scale: scale,
                      isLoading: membersState.isLoading,
                      isSendingInvites: _isSendingInvites,
                      error: membersState.errorMessage,
                      joinRequests: membersState.joinRequests,
                      members: membersState.members,
                      processingProfileIds: _processingProfileIds,
                      onBack: () => Navigator.of(context).maybePop(),
                      onRefresh: () => _loadMembers(forceRefresh: true),
                      onOpenStudentSearch: () =>
                          _openStudentSearchSheet(context),
                      onApprove: (request) =>
                          _handleJoinRequest(request, approve: true),
                      onReject: (request) =>
                          _handleJoinRequest(request, approve: false),
                    );
                  },
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
    final cubit = context.read<ClassroomCubit>();
    final selected = await showModalBottomSheet<List<StudentProfile>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => TeacherStudentInviteSearchSheet(
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
      cubit.invalidateClassroomData(
        profileId: widget.profileId,
        classroomId: widget.classroomId,
      );
      await cubit.loadMembers(
        profileId: widget.profileId,
        classroomId: widget.classroomId,
        forceRefresh: true,
      );
    } on ClassroomException catch (error) {
      if (!context.mounted) {
        return;
      }
      context.showErrorDialog(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSendingInvites = false);
      }
    }
  }
}
