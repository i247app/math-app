import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/data/async_resource.dart';
import 'package:numi/features/classroom/controllers/parent_room_controller.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/home/data/home_layout_exception.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';
import 'package:numi/features/home/helpers/home_layout_helpers.dart';
import 'package:numi/features/classroom/helpers/parent_room_helpers.dart';
import 'package:numi/features/classroom/models/parent_room_entry.dart';
import 'package:numi/features/classroom/screens/parent_room_detail_screen.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_loading.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_class_grid.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_select_student_card.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_state_card.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_completed_task_list_item.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_pending_task_list_item.dart';
import 'package:numi/features/home/helpers/parent_home_helpers.dart';
import 'package:numi/shared/widgets/app_content_section.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';

class ParentRoomTab extends StatefulWidget {
  const ParentRoomTab({
    super.key,
    required this.profiles,
    required this.activeProfile,
    required this.isActive,
    required this.activeRefreshTick,
    required this.assignmentService,
    required this.onRefreshProfiles,
    required this.onOpenClassroomTab,
    required this.onOpenProfileMenu,
    required this.bottomPadding,
    required this.onOpenExamReview,
    required this.onCreateStudentProfile,
  });

  final List<UserProfile> profiles;
  final UserProfile? activeProfile;
  final bool isActive;
  final int activeRefreshTick;
  final ClassroomExerciseService assignmentService;
  final Future<void> Function() onRefreshProfiles;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenProfileMenu;
  final double bottomPadding;
  final Future<void> Function(BuildContext context, GeneratedExam exam)
  onOpenExamReview;
  final Future<void> Function(BuildContext context) onCreateStudentProfile;

  @override
  State<ParentRoomTab> createState() => _ParentRoomTabState();
}

class _ParentRoomTabState extends State<ParentRoomTab> {
  late final HomeLayoutService _homeLayoutService = context
      .read<HomeLayoutService>();

  late final ParentRoomController _controller = ParentRoomController(
    loadLayout: (profileId) =>
        _homeLayoutService.getLayout(profileId: profileId),
  );
  HomeLayout? get _layout => _controller.state.data;
  bool get _isLoading =>
      _controller.state.isInitialLoading ||
      _controller.state.phase == AsyncPhase.idle;
  bool get _hasLoaded => _controller.state.hasData;
  String? get _errorMessage {
    final failure = _controller.state.failure;
    if (failure == null) return null;
    final cause = failure.cause;
    return cause is HomeLayoutException && cause.message.trim().isNotEmpty
        ? cause.message
        : context.getText(AppKeys.parentChildDashboardLoadFailed);
  }

  bool _hasPlayedRoomEntrance = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadLayout();
    }
  }

  @override
  void didUpdateWidget(covariant ParentRoomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final profileChanged =
        profileStableId(oldWidget.activeProfile) !=
        profileStableId(widget.activeProfile);
    if (profileChanged) {
      _resetRoomEntrance();
      _controller.selectProfile(profileStableId(widget.activeProfile));
    }
    if (!widget.isActive) return;
    if (profileChanged ||
        oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadLayout(forceRefresh: true);
    } else if (!oldWidget.isActive) {
      _loadLayout();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetRoomEntrance() {
    _hasPlayedRoomEntrance = false;
  }

  Widget _roomFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedRoomEntrance) {
      return child;
    }

    return AppStaggeredEntrance(
      order: order,
      onFinished: markOnEnd ? _markRoomEntrancePlayed : null,
      child: child,
    );
  }

  void _markRoomEntrancePlayed() {
    if (!mounted || _hasPlayedRoomEntrance) {
      return;
    }
    setState(() => _hasPlayedRoomEntrance = true);
  }

  Future<void> _loadLayout({bool forceRefresh = false}) => _controller.load(
    profileId: profileStableId(widget.activeProfile),
    forceRefresh: forceRefresh,
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) => _buildRoom(context),
  );

  Widget _buildRoom(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final parent = _layout?.parent;
    final entries = roomEntries(parent);
    final pendingExercises =
        parent?.pendingExercises ?? const <HomeLayoutPendingExercise>[];
    final expiredExercises =
        parent?.expiredExercises ?? const <HomeLayoutPendingExercise>[];
    final completions =
        parent?.recentCompletions ?? const <HomeLayoutRecentCompletion>[];
    final isEmptyRoomState =
        !_isLoading && _errorMessage == null && entries.isEmpty;
    final hideHeader = studentProfiles(widget.profiles).isEmpty;

    final colors = context.themeColors;
    return ColoredBox(
      color: isEmptyRoomState ? colors.surface : colors.pageBackground,
      child: RefreshIndicator(
        color: colors.brandStrong,
        onRefresh: () => _loadLayout(forceRefresh: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentPadding = isEmptyRoomState
                ? EdgeInsets.only(bottom: widget.bottomPadding)
                : EdgeInsets.fromLTRB(14, 24, 14, widget.bottomPadding + 24);
            final headerHeight = hideHeader ? 0.0 : topInset + 60;
            final minHeight = isEmptyRoomState
                ? math.max(
                    0.0,
                    constraints.maxHeight - headerHeight - widget.bottomPadding,
                  )
                : 0.0;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hideHeader)
                    PageHeader(
                      title: context.getText(AppKeys.parentRoomTitle),
                      topInset: topInset,
                    ),
                  Padding(
                    padding: contentPadding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minHeight),
                      child: AnimatedSwitcher(
                        key: ValueKey(profileStableId(widget.activeProfile)),
                        duration: const Duration(milliseconds: 220),
                        child: _roomContent(
                          context,
                          entries: entries,
                          pendingExercises: pendingExercises,
                          expiredExercises: expiredExercises,
                          completions: completions,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _roomContent(
    BuildContext context, {
    required List<ParentRoomEntry> entries,
    required List<HomeLayoutPendingExercise> pendingExercises,
    required List<HomeLayoutPendingExercise> expiredExercises,
    required List<HomeLayoutRecentCompletion> completions,
  }) {
    final colors = context.themeColors;
    if (_isLoading && !_hasLoaded) {
      return const ParentRoomLoading(key: ValueKey('room-loading'));
    }

    if (_errorMessage != null && entries.isEmpty) {
      return _roomFadeIn(
        markOnEnd: true,
        child: ParentRoomStateCard(
          key: const ValueKey('room-error'),
          icon: Icons.cloud_off_rounded,
          title: context.getText(AppKeys.historyLoadErrorTitle),
          message: _errorMessage!,
          onTap: () => _loadLayout(forceRefresh: true),
        ),
      );
    }

    if (entries.isEmpty) {
      return ParentRoomSelectStudentCard(
        key: const ValueKey('room-empty'),
        onChooseProfile: widget.onOpenProfileMenu,
        onCreateProfile: _openCreateStudentProfile,
      );
    }

    return Column(
      key: const ValueKey('room-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: AppRetryPanel(
              message: _errorMessage!,
              onRetry: () => _loadLayout(forceRefresh: true),
            ),
          ),
        _roomFadeIn(
          order: 0,
          markOnEnd:
              pendingExercises.isEmpty &&
              expiredExercises.isEmpty &&
              completions.isEmpty,
          child: ParentRoomClassGrid(entries: entries, onOpen: _openRoomDetail),
        ),
        if (pendingExercises.isNotEmpty || expiredExercises.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: _roomFadeIn(
              order: 1,
              markOnEnd: completions.isEmpty,
              child: AppContentSection(
                title: context.formatText(AppKeys.parentTasksCountTitle, {
                  'count': pendingExercises.length + expiredExercises.length,
                }),
                onViewAll: widget.onOpenClassroomTab,
                child: Column(
                  children: [
                    for (final pending in pendingExercises.take(3)) ...[
                      ParentPendingTaskListItem(pending: pending),
                      if (pending != pendingExercises.take(3).last ||
                          expiredExercises.isNotEmpty)
                        Divider(height: 24, indent: 62, color: colors.border),
                    ],
                    for (final expired in expiredExercises.take(3)) ...[
                      ParentPendingTaskListItem(
                        pending: expired,
                        isExpired: true,
                        onTap: () => showExpiredExerciseMessage(context),
                      ),
                      if (expired != expiredExercises.take(3).last)
                        Divider(height: 24, indent: 62, color: colors.border),
                    ],
                  ],
                ),
              ),
            ),
          ),
        if (completions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: _roomFadeIn(
              order: 2,
              markOnEnd: true,
              child: AppContentSection(
                title: context.getText(AppKeys.assessmentResultTitle),
                onViewAll: widget.onOpenClassroomTab,
                child: Column(
                  children: [
                    for (final completion in completions.take(5)) ...[
                      ParentCompletedTaskListItem(
                        completion: completion,
                        onTap: () => _openCompletionResult(completion),
                      ),
                      if (completion != completions.take(5).last)
                        Divider(height: 24, indent: 62, color: colors.border),
                    ],
                  ],
                ),
              ),
            ),
          ),
        // The Utilities section is temporarily hidden. Uncomment it and restore
        // the related imports when the section is needed again.
        /*
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: ParentRoomUtilitiesSection(
            onMessageTap: () => _openMessages(entries.first),
            onUtilityTap: () => parentRoomShowComingSoon(context),
          ),
        ),
        */
      ],
    );
  }

  void _openCompletionResult(HomeLayoutRecentCompletion completion) {
    final exam = examFromRecentCompletion(completion);
    final examId = exam.examId ?? exam.id;
    if (examId == null || examId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    widget.onOpenExamReview(context, exam);
  }

  // Reuse with the Utilities section when the feature is enabled again.
  /*
  void _openMessages(ParentRoomEntry entry) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ParentMessagesScreen(
          className: roomClassName(context, entry.classroom),
          teacherName: roomTeacherName(context, entry),
        ),
      ),
    );
  }
  */

  void _openRoomDetail(ParentRoomEntry entry) {
    HapticFeedback.selectionClick();
    final parent = _layout?.parent;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ParentRoomDetailScreen(
          entry: entry,
          pendingExercises: pendingForRoomEntry(parent, entry),
          expiredExercises: expiredForRoomEntry(parent, entry),
          completions: completionsForRoomEntry(parent, entry),
          exerciseService: widget.assignmentService,
          onRefreshLayout: _loadLayout,
        ),
      ),
    );
  }

  Future<void> _openCreateStudentProfile() async {
    HapticFeedback.selectionClick();
    await widget.onCreateStudentProfile(context);
    await widget.onRefreshProfiles();
    if (mounted) {
      await _loadLayout(forceRefresh: true);
    }
  }
}
